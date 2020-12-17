#12월 17일 4.2 조건에 따라 결합할 마스터 테이블 변경하기

#데이터 분석 전처리에는 특별한 전처리가 요구되기도 한다. 값에 따라 결합 대상을
#변경하는 결합 처리도 그중 하나이다. 예를 들어 호텔 예약 사이트에서 호텔별로
#다른 호텔을 추천하고 싶은 상황을 생각해봅시다.
# 특정 A호텔에 대해서 A호텔을 제외한 모든 호텔이 추천 대상이 되므로
#추천 후보가 되는 호텔 수는 (모든 호텔수 -1 )입니다. 모든 호텔의 조합
#(A에서 B의 추천과 B에서 A의 추천은 다른 것으로 생각한다.)에서
#호텔별 우선 순위를 매겨야 한다. 모든 호텔 수가 1천 건 정도라도 
#1000 X (1000-1) = 약 백만건으로 늘어난다. 이 정도는 계산할 수 있겠지만
#만약 건수가 1만 건만 돼도 조합은 약 1억가까이 늘어나 쉽게 계산할 수 없게 된다.

#이러한 문제를 해결하기 위해 같은 지역의 호텔만을 추천하여 호텔의 추천 후보
#수를 줄일수는 있지만, 이는 또 다른 문제를 일으킨다. 지역에 따라 호텔수가
#충분하지 않아 추천후보가 부족하게 되는 것이다. 이 문제는 대상 지역을 넓혀서
#호텔을 추천하는 식으로 대응할 수 있으며, 조건에 따른 결합 처리가 필요하다.

#조건에 따른 결합 처리는 코드가 복잡해질 수 밖에 없다. 기본적으로 우선
#결합할 테이블에 각 조건식에서 참조할 결합 키를 위한 열을 새로 생성한 후
#두 개의 마스터 테이블에서 결합에 필요한 공통 열로하나의 테이블을 만든다.
#그리고 마지막으로 테이블을 결합한다.

#Q1. 마스터 테이블 변경

#데이터 셋은 호텔 예약 레코드를 사용한다. 호텔 테이블에 있는 모든 호텔에
#추천 후보 호텔을 연결한 데이터를 작성한다. 같은 소규모 지역단위
#(small_area_name)에 추천 후보 수가 20건 이상이면 같은 소규모 지역 단위의
#호텔을 후보로 하고, 같은 소규모 지역 단위의 호텔 건수가 20건 미만이면
#같은 대규모 지역 단위(big_area_name)의 호텔을 추천 후보로 한다.

#R
#단계적으로 작성할 수 있다. 또한 dplyr패키지의 파이프라인으로 처리의 흐름도
#알기 쉽게 작성할 수 있다. 데이터크기에 따른 메모리 사용량에 주의하면서
#불필요한 복제를 최대한 줄이도록 하자

#-- small_area_name별로 호텔 수를 카운팅하고, 결합 키를 판정하기 위한 테이블
small_area_mst <- hotel_tb %>% 
  group_by(big_area_name, small_area_name) %>% 
  
  # -1로 자신을 제외한다.
  summarise(hotel_cnt = n() -1 ) %>% 
  
  #집약 처리 후에 그룹화를 해제한다.
  ungroup() %>% 
  
  #20건 이상이면 join_area_id을 small_area_name으로서 지정한다.
  #20건 미만이면 join_area_id을 big_area_name으로서 지정한다.
  mutate(join_area_id = 
           if_else(hotel_cnt >= 20, small_area_name, big_area_name)) %>% 
  select(small_area_name, join_area_id)

#추천 후보 대상 호텔에 small_area_mst를 결합하여 join_area_id를 설정한다.
base_hotel_mst <-
  inner_join(hotel_tb, small_area_mst, by = 'small_area_name') %>% 
  select(hotel_id, join_area_id)

#필요에 따라 메모리를 해제한다.(필수는 아니지만, 메모리에 여유가 없을때 사용)
rm(small_area_mst)

#recommend_hotel_mst는 추천 후보 테이블
recommend_hotel_mst <- 
  bind_rows(
    #join_area_id를 bid_area_name으로 한 추천 후보 마스터
    hotel_tb %>% 
      rename(rec_hotel_id = hotel_id, join_area_id = big_area_name) %>% 
      select(join_area_id, rec_hotel_id),
    
    #join_area_id를 small_area_name으로 한 추천 후보 마스터
    hotel_tb %>% 
      rename(rec_hotel_id = hotel_id, join_area_id = small_area_name) %>% 
      select(join_area_id, rec_hotel_id)
  )

#base_hotel_mst와 recommend_hotel_mst를 결합하여 추천 후보 정보를 부여한다.
inner_join(base_hotel_mst, recommend_hotel_mst, by = 'join_area_id') %>% 
  
  #추천 후보에서 자신을 제외한다.
  filter(hotel_id != rec_hotel_id) %>% 
  select(hotel_id, rec_hotel_id)


#ifelse함수는 조건에 따라 반환하는 값을 변경할 수 있는 함수이다.
#첫 번쨰 매개변수의 조건을 충족하면 두번째 매개변수의 값을 반환하고, 
#충족하지 못하면 세 번쨰 매개변수의 값을 반환한다.

#bind_rows 함수는 첫 번째 매개변수의 data.frame과 두번 쨰 매개변수의
#data.frame을 연결한다.

#R에서는 세 개의 테이블을 한꺼번에 결합할 수 없어서 먼저 추천 후보 대상
#호텔의 테이블과 추천 후보를 찾기 위한 small_area_mst를 결합하여
#base_hotel_mst를 생성한다. 코드는 조금 길어지지만, 로직의 흐름이 알기 쉬운
#awosome한 코드다!