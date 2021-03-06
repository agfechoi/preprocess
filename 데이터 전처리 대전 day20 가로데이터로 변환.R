#1월 4일 7장 전개

#데이터 집계 결과를 표형식으로 변환하는 전개는 전처리에서 빼놓을 수 없다.
#예를 들면 다음과 같은 경우에 전개 처리를 이용한다.

#1. 간단한 집계 처리의 결과를 보기 쉽게 하기 위해 이용한다.
#2. 추천 항목에 사용할 데이터를 준비할 때 이용한다.

#일부 분석학자들은 데이터를 표 형식으로 변환하는 처리를 수작업으로 처리한다.
#SQL로 구현하는 것은 매우 귀찮은 작업이며 R이나 파이썬은 흔히 사용되지 않는
#방법이다. 

#7.1 가로 데이터로 변환
#데이터셋은 호텔 예약 레코드를 사용한다. 예약 테이블에서 고객 수 및 투숙객 수에
#따른 예약 건수를 세서 행을 고객ID, 열을 투숙객 수, 값을 예약 건수엔 표로
#변환하자.

#R
#가로 데이터로 변환했을 때 열 이름을 구할 수 있도록 범주형(factor)으로
#변경한다. 범주형은 9장에서 자세히 설명한다.
reserve_tb$people_num <- as.factor(reserve_tb$people_num)

reserve_tb %>% 
  group_by(customer_id, people_num) %>% 
  summarise(rsv_cnt = n()) %>% 
  
  #spread함수를 이용해 가로 데이터로 변환한다.
  #fill에 값이 없을 때의 값을 설정한다.
  spread(people_num, rsv_cnt, fill = 0)

#spread함수를 이용하여 간략하게 가로 데이터로 변환하였다.
#가로 데이터로 만들기 전 dplyr로 집약 처리를 하고 파이프로 연결하여
#spread 함수를 사용해 처리의 흐름을 알기 쉽도록 작성한 awesome한 코드다