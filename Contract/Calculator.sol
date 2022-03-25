pragma ton-solidity >=0.57.0;
pragma AbiHeader pubkey;
pragma AbiHeader expire;
pragma AbiHeader time;

contract Calculator{

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(tvm.pubkey() == msg.pubkey(), 102);
        tvm.accept();
    }

    function addition(int x, int y) public pure returns (int){
        return x + y;
    }

    function subtraction(int x, int y) public pure returns (int){
        return x - y;
    }

    function multiplication(int x, int y) public pure returns (int){
        return x * y;
    }

    function division(int x, int y)  public pure returns (int){
        return x / y;
    }
}
