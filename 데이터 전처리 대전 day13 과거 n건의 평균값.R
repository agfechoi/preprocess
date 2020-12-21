#12월 21일 과거 n건의 평균값

#데이터셋은 호텔 예약 레코드를 사용. 예약 테이블의 모든 행에 자신의 행을
#포함하지 않고 한 건 이전의 데이터에서 세 건 이전까지의 평균 예약 금액을 첨부,
#과거 예약 건수가 세 건 미만이면 존재하는 건수의 평균값을 계산.
#예약이 한 건도 없으면 값을 가지지 않는다. 

#R
#RcppRoll 패키지의 roll함수는지정한 건수를 만족하지 못하면 계산이 실행되지
#않는다. lag함수와 조합하여 구현하자

#row_number함수로 reserve_datetime을 사용하기 위해 POSIXct형으로 변환한다.
#(10장에서 자세히 설명한다.)
reserve_tb$reserve_datetime <-
  as.POSIXct(reserve_tb$reserve_datetime, format = '%Y-%m-%d %H:%M:%S')

reserve_tb %>% 
  group_by(customer_id) %>% 
  arrange(reserve_datetime) %>% 
  
  # 1 - 3건 이전의 total_price의 합계를 lag함수로 계산한다.
  #if_else 함수와 rank함수를 조합하여 계산한 건수를 판별한다.
  #order_by = reserve_datetime을 지정하는 것은 미리 정렬되어 있어서
  #필수사항은 아니다.
  #계산된 건수가 0이면 분모가 0이므로 price_avg가 NAN이 된다.
  mutate(price_avg = 
           (lag(total_price, 1, order_by = reserve_datetime, default = 0)
            + lag(total_price, 2, order_by = reserve_datetime, default = 0)
            + lag(total_price, 3, order_by = reserve_datetime, default = 0))
         / if_else(row_number(reserve_datetime) > 3,
                   3, row_number(reserve_datetime) - 1))

#lag함수와 row_number함수를 조합하여 평균값을 구한다. lag함수를 사용하여
#한 건 이전, 두 건 이전, 세 건 이전의 데이터를 각각 구하여 합계를 계산한다.
#만약 해당 데이터가 없으면 default 매개변수에 지정한 0이 할당 되므로
#대상 건수가 한두 건이어도 합계가 계산된다.

#row_number함수는 같은 customer_id별로 붂인 reserve_datetime을 기준으로 정렬된
#그룹에서 몇 번째 데이터인지 판별한다. 이 값을 if_else 함수로 판별하여
#세건보다 크면 3을, 세 건 이하이면 row_number 함수로 계산된 값에서 1을 뺀
#값을 반환하여 과거 데이터 건수를 계산한다.

#lag함수는 합계를, row_number 함수는 계산한 건수를 구하여 두 값의 평균값을
#구한다.

#총평
#lag함수를 반복해서 사용하고 복잡한 분기가 있어서 가독성이 낮다.
#또한 참조하는 건수가 증가할수록 코드 작성량도 늘어나므로 유연하지 못하고
#불필요한 계산을 반복하게 되는 now awesome한 코드이다. 단 zoo라이브러리의
#rollapplyr함수를 사용하면 R에서도 간단하게 구현할 수 있다.

