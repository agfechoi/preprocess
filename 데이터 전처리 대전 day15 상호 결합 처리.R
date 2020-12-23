#12월 23일 4.4 상호결합

#앞 절까지는 결합 키가 있는 경우를 소개했는데, 데이터 분석은 결합 키를 지정하지
#않는 전체 결합이 필요한 경우가 있다. 상호결합이란 결합하는 양쪽 테이블을
#모두 조합하여 생성하는 결합이다. 주로 집계나 학습 데이터를 만들기 위한 전처리에서
#사용됩니다.

#예를 들어 고객의 월별 사용 금액을 집계하는 상황을 가정해봅시다. 예약 테이블이
#있으면 고객과 월별 사용 금액을 집약하여 사용 금액을 계산 할 수 있지만,
#특정 고객이 특정 월에 사용한 내역이 없으면 예약 레코드가 존재하지 않아
#해당 월의 사용 금액은 0이 되지 않습니다.

#이러한 문제는 상호 결합을 통해 해결할 수 있다. 미리 고객 id와 집계 대상인
#기간의 월을 상호 결합하고 예약 레코드를 결합하여 사용 금액이 0원이 되도록 한다.
#이처럼 대상 레코드가 없지만 레코드를 생성하고 싶을 때는 상호 결합이 유용하다.
#다만 상호 결합은 모든 조합으로 생성하기 때문에 데이터가 커져 가능한 최소한의
#범위에서 실행해야 한다.

#Q1. 상호 결합 처리
#데이터셋은 호텔 예약 레코드를 사용한다. 고객별로 2017년 1월에서 3월까지의 합계
#사용 금액을 계산한다. 사용이 없는 달은 0으로 하고, 날짜는 체크인 날짜를 이용한다.

#R
#dplyr패키지가 제공하는 join함수는 상호 결합을 지원하지 않는다. 결합할 양쪽
#테이블에 모두 같은 값의 결합 키를 가지도록 하여 구현할 수는 있지만,
#R이 기본으로 제공하는 merge함수를 사용하여 구현할 수도 있다.

library(tidyverse)

#계산 대상의 연월 데이터 프레임을 작성한다.
month_mst <- data.frame(year_month =
                          #2017-01-01, 2017-02-01, 2017-03-01을 생성하여
                          #format함수로 형식을 연월로 변환한다.
                          #날짜 자료형은 10장에서 자세히 설명한다.
                          format(seq(as.Date('2017-01-01'), as.Date('2017-03-01'),
                                     by = 'months'), format = '%Y%m'))
customer_tb <- read.csv("customer.csv", header = T, fileEncoding = 'utf-8',
                        stringsAsFactors = F)
#고객 id와 계산 대상의 모든 연월이 결합된 테이블
customer_mst <- 
  #모든 고객이 id와 연월 마스터를 상호 결합한다.
  merge(customer_tb %>% select(customer_id), month_mst) %>% 
  
  #merge로 지정한 결합 키의 자료형이 범주형이므로 문자열로 변환한다.
  #(범주형은 9장에서 자세히 설명한다.)
  mutate(customer_id = as.character(customer_id),
         year_month=as.character(year_month))

#합계 사용 금액을 월별로 계산한다.
left_join(
  customer_mst,
  
  #예약 테이블에 연월 결합 키를 준비한다.
  reserve_tb %>% 
    mutate(checkin_month = format(as.Date(checkin_date), format = '%Y%m')),
  
  #같은 customer_id와 연월을 결합한다.
  by=c('customer_id' = 'customer_id', 'year_month' = 'checkin_month')
) %>% 
  
  #customer_id와 연월로 집약한다.
  group_by(customer_id, year_month) %>% 
  
  #합계 금액을 계산한다.
  summarise(price_sum = sum(total_price)) %>% 
  
  #예약 레코드가 없을 때 합계 금액을 값이 없음에서 0으로 변환한다.
  replace_na(list(price_sum = 0))

##seq에 날짜를 지정하고 by에 month를 지정하여 월 단위의 날짜를 생성하고
#format으로 문자열을 변환하여 연월 마스터 테이블을 만든다. 날짜형의 변환에
#대해서는 10장에서 자세히 설명한다.

##merge함수는 기본 R이 제공하는 결합 함수이다. 보통 결합에서는 결합키를
#지정해야 하지만, 상호 결합은 결합키를 지정하면 안된다. 또한 merge 함수를
#사용하면 결합 키의 문자열이 범주형(factor형)이 되므로 주의해야한다.

#상호 결합은 처리가 무거워지기 쉬워서 최소한의 열이 대상이 되도록
#설계된다. 코드가 조금 길어졌지만 좋은 코드다.
