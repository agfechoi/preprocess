#12월 22일 과거 n일의 합곗값

#데이터 셋은 호텔 예약 레코드를 사용. 예약 테이블의 모든 데이터에 자신을
#포함하지 않으면서 같은 고객의 지난 90일간의 합계 예약 금액 정보를 첨부하자
#예약이 하나도 없으면 값을 0으로 하자.

#R
#현재 dplyr 패키지는 join 함수에서 부등식을 지정할 수 없다. 따라서 등식으로
#가능한 한 결합 대상을 줄여 결합한 후 부등식으로 원하는 데이터를 만들어야한다.

library(tidyr)
#row_number 함수로 reserve_datetime을 사용하기 위해 POSIXct형으로 변환한다.
#(10장에서 자세히 설명한다)
reserve_tb$reserve_datetime <-
  as.POSIXct(reserve_tb$reserve_datetime, format = '%Y-%m-%d %H:%M:%S')

#지난 90일 간의 예약 금액 합계를 계산한 테이블
sum_table <-
  
  #reserve_datetime날짜를 확인하지 않고 customer_id가 같은 데이터들을 모두 결합
  inner_join(
    reserve_tb %>% 
      select(reserve_id, customer_id, reserve_datetime),
    reserve_tb %>% 
      select(customer_id, reserve_datetime, total_price) %>% 
      rename(reserve_datetime_before = reserve_datetime),
    by= 'customer_id') %>% 
  
  #checkin의 날짜를 비교하여 90일 이내 데이터가 결합된 데이터만을 추출한다.
  #60*60*24*90은 60초*60분*24시간*90일을 의미하고, 90일분의 초를 계산한다.
  #(날짜 데이터 형식은 10장에서 자세히 설명한다.)
  filter(reserve_datetime > reserve_datetime_before &
           reserve_datetime - 60*60*24*90 <= reserve_datetime_before) %>% 
  select(reserve_id, total_price) %>% 
  
  #reserve_id별로 total_price의 합을 계산한다.
  group_by(reserve_id) %>% 
  summarise(total_price_90d = sum(total_price)) %>% 
  select(reserve_id, total_price_90d)

#계산된 합을 결합하여 원본 테이블에 정보를 첨부한다.
#합곗값이 없는 레코드의 합곗값을 replace_na를 사용하여 0으로 변환한다.
left_join(reserve_tb, sum_table, by = 'reserve_id') %>% 
  replace_na(list(total_price_90d = 0))

#inner_join함수 부분에서 같은 customer_id인 자료형을 모두 결합하여
#중간 데이터 크기가 커진다. 그 결과 필요한 메모리가 많아지면서
#처리도 느려진다. 코드도 길고 번잡한 별로 안예쁜 코드다.