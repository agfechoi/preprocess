install.packages("tidyverse")

library(tidyverse)

setwd("C:/Users/최은철/Desktop/data")
reserve_tb <- read.csv("reserve.csv", header = TRUE, fileEncoding = 'UTF-8',
                       stringsAsFactors = FALSE)

#필요한 열만 가져오기

#NOT AWESOME한 방법1
#reserve_tb의 2차원 배열의 1차원 항목을 빈 값으로 하여 모든 행을 추출한다.
#reserve_tb의 2차원 배열의 2차원 항목에 숫자 벡터값을 지정하여
#여러 행을 추출할 수 있다.

reserve_tb[, c(1,2,3,4,5,6,7)] #1~7번째 열 추출
#이 방법은 이후에 열이 추가되거나 하면 쓰기 번거로워 질 뿐더러
#이름을 쓴게 아니라 무슨 열을 가져온건지 알기 어렵다.

#Awesome한 방법1
#reserve_tb의 2차원 배열의 2차원 항목(열)에 문자 벡터로 추출할 열 이름 지정
reserve_tb[, c('reserve_id', 'hotel_id', 'customer_id', 'reserve_datetime',
               'checkin_date', 'checkin_time', 'checkout_date')]
#date.frame은 행/열 번호를 숫자가 아닌 문자 벡터로도 지정가능
#이렇게 하면 순서가 변경되거나 새로운 열이 추가되거나 해도 정확히 그 열을
#추출해서 가져오며 무슨 열을 가져온건지 바로 알 수 있다.

#Awesome한 방법2
#dplyr패키지 사용
reserve_tb %>% select(reserve_id, hotel_id, customer_id, reserve_datetime,
                      checkin_date, checkin_time, checkout_date)
#select 함수의 매개변수로 추출할 열 이름을 입력해서 열을 추출한다.

#이 방법을 쓰면 가독성도 좋아지고 뒤에 %>% 를 붙여서 추가적인 처리를 하기 쉽다

#NOT AWESOME한 방법2
reserve_tb %>% 
  select(reserve_id, hotel_id, customer_id, reserve_datetime,
         starts_with('check'))
#select의 매개변수에 열 이름외에도 함수를 이용하여 열을 지정할 수 있다,
#언뜻보기에는 좋아보인다.
#starts_with(string) : 지정한 문자열로 시작하는 이름을 가진 열을 가져온다.
#ends_with(string) : 지정한 문자열로 끝나는 이름을 가진 열을 가져온다.
#contains(string) : 지정한 문자열을 포함하는 이름을 가진 열을 가져온다.
#matches(string) : 지정한 정규 표현으로 매칭된 열을 가져온다.
#하지만 코드만 봐서는 지정된 열 이름을 알 수 없고, check라는 접두사가 붙은
#다른 열이 추가되면 추출되는 결과가 달라진다. 이러한 함수는 결과값을
#일시적으로 확인하고 싶을때만 사용하는 것으로 권장한다.

