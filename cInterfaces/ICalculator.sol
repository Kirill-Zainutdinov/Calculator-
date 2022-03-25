pragma ton-solidity >=0.57.0;
pragma AbiHeader pubkey;
pragma AbiHeader expire;
pragma AbiHeader time;

interface ICalculator {
    function addition (int x, int y) external returns (int);
    function subtraction (int x, int y) external returns (int);
    function multiplication (int x, int y) external returns (int);
    function division (int x, int y) external returns (int);
}
