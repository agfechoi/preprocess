#12월 14일 3.6 순위 계산

#전처리 과정 중에 순위를 계산해야 하는 경우가 종종 있다.
#대상 데이터를 추리거나 복잡한 시간 데이터를 결합할때 시간 순서로 순위를 매겨서
#결합의 조건으로 이용할 수도 있다. 순위를 매길 때는 계산 비용을 고려해야 하는데
#이때 정렬 기능도 구현해야 하므로 데이터 수가 많으면 계산 비용이 비약적으로
#늘어납니다. 하지만 순위를 매기는 범위를 나누는(사용자별로 로그를 시간 순서로
#정렬하는 등) 처리 등으로 계산 비용을 줄일 수 있다. 이처럼 그룹별로 순서를
#정렬하고 순위를 매기는 계산은 Window함수를 이용하면 간략하고 성능 좋은
#코드를 작성할 수 있다. windows함수는 집약 함수 중에 하나인데
#일반적인 집약 함수와 비교하여 행을 집약하는 것이 아니라
#집약한 결과를 계산하여 각 행에 첨부하는 점이 다르다.

#순위를 구하는 함수
#R의 경우 dense_rank라는 함수가 있다. 이 함수는 같은 값을 가진 경우
#공동순위를 매기고 그 다음순위로 넘어간다.

#시간 데이터에 번호 부여
#데이터 셋은 호텔 예약 레코드를 사용한다. 
#예약 테이블을 이용하여 고객별 예약 시간에 따른 순위를 매긴다.
#같은 시간에 예약한 경우에는 읽어드린 데이터 순으로 순위를 매긴다.


#R에서 같은 값의 순위를 어떻게 처리할 것인가에 따라 사용할 함수가 달라진다.
#예제에서는 row_number 함수를 사용한다.

#row_number 함수로 정렬하기 위해서 자료형을 문자열에서 POSTXct형으로 변환한다.
#(10장에서 더 자세히 설명)
getwd()
setwd("C:/Users/최은철/Desktop/data")

reserve_tb <- read.csv("reserve.csv", header = T, fileEncoding = 'utf-8',
                       stringsAsFactors = F)

reserve_tb$reserve_datetime <-
  as.POSIXct(reserve_tb$reserve_datetime, format = '%Y-%m-%d %H:%M:%S')
library(dplyr)
a <- reserve_tb %>% 
  #group_by 함수를 사용하여 집약 단위를 지정한다.
  group_by(customer_id) %>% 
  #mutate 함수로 log_no라는 열을 새롭게 추가한다.
  #row_number 함수로, 예약 시간을 기준으로 해 순위를 계산한다.
  mutate(log_no = row_number(reserve_datetime))
View(a)

#mutate 함수는 data.frame에 새로운 열을 추가할 수 있는 함수이다.
#등호 (=) 왼쪽에 새로운 열 이름을, 오른쪽에 새로운 열의 값을 지정한다.

#row_number 함수는 순위를 계산하는 함수이다. 문자열의 순위를 계산할 수 
#없기 때문에 시간과 같은 문자열 데이터는 크기를 비교할 수 있는 시간 데이터로
#변환해야 한다. 일시형 데이터에 대해서는 10장에서 자세히 설명한다.

#dplyr패키지는 window 함수를 이용할 때도 간략하고 처리 효율이 좋은
#코드를 작성할 수 있다. mutate함수를 이용하여 추가되는 새로운 열을
#알아보기 쉽게 작성한 Awesome한 코드이다.