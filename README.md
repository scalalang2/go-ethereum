## Geth / BASELAB
본 레포지토리는 실험용 geth 입니다.

#### Geth 설치하기
1. go 언어 설치
2. go get github.com/scalalang2/go-ethereum 으로 소스코드 내려 받기
3. `go mod tidy && go mod vendor` 명령어로 의존성 패키지 다운로드

#### Geth 실행하기 Mac
```sh
$ make geth
$ ./build/bin/geth
```

#### Geth 실행하기 Windows
```sh
$ go install -v ./cmd/...
$ geth
```

#### Geth Console 접근하기
```sh
$ ./build/bin/geth attach
> eth.syncing
```

## Geth 동기화
* Full - 모든 블록 내용을 다운로드 받는다.
* Fast(default) - 최근 < N-K번째 블록까지는 블록 헤더만 다운로드 하고 > N-K 인 블록은 블록 내용까지 다운로드하여 동기화 속도를 높인다.
* Light - 블록 헤더와 데이터만 받고 랜덤하게 몇개 블록만 선정해서 검증한다. 가장 빠르게 부팅하는 방법 중 하나

#### 실험용 데이터 수집 활성화 하기
```sh
./build/bin/geth \
    --measure.dsn <dsn> \
```

## 분석
#### EVM의 OPCODE별 소요시간 측정하기
모든 EVM의 OPCODE는 Go언어 함수로 구현되어 있다.
함수의 시작점 및 끝에 시간을 측정하는 코드를 추가하면 쉽게 바이트 코드 단위의 소요시간을 측정할 수 있다.

```go
// -- core/vm/instruction.go
func opExtCodeSize(pc *uint64, interpreter *EVMInterpreter, callContext *callCtx) ([]byte, error) {
	defer measureTime(time.Now(), "EXTCODESIZE")
	slot := callContext.stack.peek()
	slot.SetUint64(uint64(interpreter.evm.StateDB.GetCodeSize(common.Address(slot.Bytes20()))))
	return nil, nil
}
```

추가로 블록 넘버와 컨트랙트를 수행한 계정의 주소와 같이 통계치를 뽑아내는데 도움이 되는 정보는 함수의 인자로 받은 `interpreter`와 `callContext` 변수를 이용하면 추가적인 정보도 기입할 수 있다. EVMInterpreter 구조체 안에 있는 Context 구조체에는 아래 정보가 포함되어 있다.

```go
type Context struct {
	CanTransfer CanTransferFunc
	Transfer TransferFunc
	GetHash GetHashFunc

	// Message information
	Origin   common.Address 
	GasPrice *big.Int      

	// Block information
	Coinbase    common.Address 
	GasLimit    uint64         
	BlockNumber *big.Int       
	Time        *big.Int       
	Difficulty  *big.Int       
}
```

#### 데이터 저장용 스토리지 생성
본 실험 코드에서는 실시간으로 대용량 데이터를 저장하기 위해 MongoDB를 이용한다.