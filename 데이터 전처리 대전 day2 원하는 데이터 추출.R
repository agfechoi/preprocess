#조건에 따른 데이터 행 추출

#호텔 예약 레코드 데이터 셋에서 checkin_date가 2016-10-12 ~ 2016-10-13까지인 행
#추출해보기

reserve_tb <- read.csv("reserve.csv", header = TRUE, fileEncoding = 'utf-8',
                       stringsAsFactors = FALSE)

#NOT AWESOME한 방법1
#checkin_date의 조건식에 따라 판정 결과의 TRUE/FALSE 벡터값을 얻는다.
#조건식을 &로 연결하여 판정 결과가 TRUE인 경우에만 TRUE가 되는
#벡터값을 얻는다.
#reserve_tb의 2차원 배열의 1차원 항목에 TRUE/FALSE의 벡터값을 지정하여
#조건에 맞는 행을 추출한다.
#reserve_tb의 2차원 배열의 2차원 항목에 빈 값을 설정하여 모든 열을 추출한다.

reserve_tb[reserve_tb$checkin_date >= '2016-10-12' &
             reserve_tb$checkin_date <= '2016-10-13', ]

#조건식을 작성할때 reserve_tb가 반복되므로 읽기 쉬운 코드라고 보기 어렵다
#TRUE/FALSE벡터에 의한 추출은 행/열 번호를 지정하는 것보다 처리가 느리다.
#게다가 데이터양이 많아지면 그 차이는 더욱 커진다.
#계산 비용 측면에서 not awesome하다

#NOT AWESOME한 방법2
#which함수에 조건식을 지정하여 판정 결과가 TRUE가 되는 행 번호 벡터를 얻는다.
#intersect함수로 두 매개변수에 동시에 출현하는 행 번호만 선택한다.
#reserve_tb의 2차원 배열의 1차원 항목에 행 번호 벡터를 지정하여 조건을 만족
#하는 행을 추출한다.

reserve_tb[
  intersect(which(reserve_tb$checkin_date >= '2016-10-12'),
            which(reserve_tb$checkin_date <= '2016-10-13')), ]

#which함수를 이용하면 TRUE/FALSE 벡터에서 TRUE인 요소의 인덱스 벡터로 변환
#TRUE/FALSE 벡터는 벡터의 길이가 데이터의 행/열의 수가 되지만, 번호 벡터로
#변환하면 벡터의 길이를 TRUE인 행/열의 수로 줄일 수 있다.

#intersect함수는 모든 벡터 매개변수에 공통으로 존재하는 요소들만 반환해서
#조건을 동시에 만족하는 행/열 번호를 추출할때 사용할 수 있다.
#조건식 중 하나 이상을 충족하는 추출에는 intersect함수 대신에 union 함수를
#사용할 수 있으며, union함수는 벡터 매개변수에 존재하는 모든 요소를 반환

#쉽게 말해서 intersect는 교집합, union은 합집함이다.
intersect(c(1,3,5), c(1,2,5)) #결과는 c(1,5)
union(c(1,3,5), c(1,2,5)) #결과는 c(1,3,5,2)

#행번호에 따라 데이터가 축소되므로 계산비용 측면에서는 문제가 없다.
#하지만 앞 예시에 비해 사용하는 함수가 불필요하게 많아지고 가독성도 별로다
#고로 not awesome

#NOT AWESOME한 방법3
reserve_tb %>% 
  filter(checkin_date >= '2016-10-12' & checkin_date <= '2016-10-13')
#filter함수에 checkin_date조건을 넣어 조건 만족하는 행을 추출

#매우 간결하고 좋지만 한가지 아쉽다. checkin_date의 조건을 2개로 나누어서
#지정하다보니 가독성이 조금 떨어진다는 것이다.

#AWESOME한 방법1
reserve_tb %>% 
  filter(between(as.Date(checkin_date),
                 as.Date('2016-10-12'), as.Date('2016-10-13')))

#between함수는 특정 열의 값에 대한 범위 조건을 지정할 수 있다.
#첫 번째 매개변수에는 열의 값을, 두번째와 세번째 매개변수에는 범위를 지정한다.
#between함수는 문자열을 처리할 수 없으므로 자료형을 날짜형으로 변환해야한다.
#as.Date함수가 그 역할을 하였다.

#between함수를 이용하여 checkin_date의 범위를 한번에 지정하므로 코드가
#간결해졌다. 계산비용 측면으로도 awesome하다.
