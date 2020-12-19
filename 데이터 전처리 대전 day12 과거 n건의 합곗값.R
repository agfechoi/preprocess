#12월 19일 과거 n건의 합곗값

#Q2. 데이터셋은 호텔 예약 레코드를 사용한다. 예약 테이블의 모든 행에 자신의
#행에서 같은 고객의 이전 예약 세 건의 예약 금액 정보를 추출하자. 과거 예약
#건수가 세 건 미만이면 없음으로 표시하자.

#R
#R에는 합계를 계산하는 window 함수의 roll_sum함수가 RcppRoll 패키지에서 제공
#된다. 이 함수를 사용하여 awesome한 콛를 구현할 수 있다.

#roll_sum 함수를 사용하기 위한 라이브러리
install.packages("RcppRoll")
library(RcppRoll)

reserve_tb %>% 
  #데이터 행을 customer_id별로 그룹화 한다.
  group_by(customer_id) %>% 
  
  #customer_id별로 reserve_datetime으로 데이터 정렬한다.
  arrange(reserve_datetime) %>% 
  
  #RcppRoll의 roll_sum으로 이동 합곗값을 계산한다.
  mutate(price_sum = roll_sum(total_price, n=3, align = 'right', fill = NA))

#RcppRoll 패키지의 roll_sum함수는 합계를 계산하는 window함수이다.
#n으로 합곗값을 계산할 대상 건수를 지정할 수 있고, align으로 대상
#데이터를 결정할 기준을 설정할 수 있다.

#right : 대상 데이터를 포함한 앞부분을 대상으로 한다.
#left : 대상 레코드를 포함한 뒷부분을 대상으로 한다.
#center : 대상 레코드를 가운데로 해 앞뒤를 대상으로 한다.

#또한 roll_sum함수는 대상 데이터 수가 지정한 n건을 만족하지 않으면 모든 값이
#NA가 되는데, 이는 fill 매개변수로 NA 대신 지정한 고윳값으로 채울수도 있다.
#이번 예제에서는 값이 NA가 되어도 상관없지만 지정한 n건을 만족하지 못할 경우
#fill 매개변수를 이용하여 처리하기엔 다소 부족하다. RcppRoll 패키지는
#roll_sum함수외에 roll_mean, roll_median, roll_min, roll_prod, roll_sd,
#roll_var함수가 제공된다.

#RcppRoll패키지와 dplyr 패키지를 함께 사용하여 간략하고 처리 속도가 빠른
#코드를 구현했다. 다만 데이터 수가 지정한 n건에 미치지 못하는 경우에는
#RcppRoll 패키지 사용을 권하지 않는다.