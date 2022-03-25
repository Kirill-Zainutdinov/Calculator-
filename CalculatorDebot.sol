pragma ton-solidity >=0.57.0;
pragma AbiHeader pubkey;
pragma AbiHeader expire;
pragma AbiHeader time;

// Подключение библиотек и интерфейсов дебота
import "dLibraries/Debot.sol";
import "dInterfaces/Terminal.sol";
import "dInterfaces/NumberInput.sol";
import "dInterfaces/Menu.sol";

// Подключение интерфейса контракта
import "cInterfaces/ICalculator.sol";

contract CalculatorDebot is Debot {

    address addrCalculator;
    uint32 idOperation;
    int x;

    constructor(address _addrCalculator) public {
        require(tvm.pubkey() != 0, 101);
        require(tvm.pubkey() == msg.pubkey(), 102);
        tvm.accept();
        addrCalculator = _addrCalculator;
    }

    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Calculator Debot";
        version = "0.0.1";
        publisher = "MSHP";
        key = "";
        author = "Kirill Zaynutdinov";
        support = address.makeAddrStd(0, 0x0);
        hello = "Hello, I'm Calculator DeBot";
        language = "en";
        dabi = m_debotAbi.get();
        icon = "";
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [
            NumberInput.ID,
            Menu.ID,
            Terminal.ID
        ];
    }

    function setCalculatorAddress(address _addrCalculator) public {
        tvm.accept();
        addrCalculator = _addrCalculator;
    }

    // Начало работы дебота
    function start() public override {
        // Вызов функции mainMenu()
        mainMenu();
    }

    function mainMenu() public {

        // Выводим меню и вызываем функции setOperation()
        Menu.select("==What to do?==", "", 
        [
            MenuItem("Addition", "", tvm.functionId(setOperation)),
            MenuItem("Subtraction", "", tvm.functionId(setOperation)),
            MenuItem("Multiplication", "", tvm.functionId(setOperation)),
            MenuItem("Division", "", tvm.functionId(setOperation)),
            MenuItem("Exit", "", tvm.functionId(exit))
        ]);
    }

    // В эту функцию передаётся индекс выбранного нами пункта меню
    function setOperation(uint32 index) public {
        Terminal.print(0, format("Chosen: {}", index));
        // В зависимости от введёного значения записывает в idOperation
        // Id одной из четырёх функций: addition(), subtraction(), multiplication(), division()
        if ( index == 0 ) {
            idOperation = tvm.functionId(addition);
        } else if ( index == 1 ) {
            idOperation = tvm.functionId(subtraction);
        } else if ( index == 2 ) {
            idOperation = tvm.functionId(multiplication);
        } else if ( index == 3 ){
            idOperation = tvm.functionId(division);
        } 
        // NumberInput.get() - принимает значение, вызывает функцию setX и передаёт ей это значение в качестве аргумента
        NumberInput.get(tvm.functionId(setX), "input first number:", -1000000, 1000000);
    }

    // setX() функция сохраняет полученное значение в х
    // B ещё раз считывает значение и вызывает функцию idOperation(), передавая ей это значение
    function setX(int value) public {
        x = value;
        NumberInput.get(idOperation, "input second number:", -1000000, 1000000);
    }

    // В зависимости от того, Id какой функции было сохранено idOperation запускается одна из этих функций

    function addition(int value) public view {
        optional(uint256) none;
        ICalculator(addrCalculator).addition{
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(printResult),
            onErrorId: tvm.functionId(onError)
        }(x, value).extMsg;
    }

    function subtraction(int value) public view {
        optional(uint256) none;
        ICalculator(addrCalculator).subtraction{
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(printResult),
            onErrorId: tvm.functionId(onError)
        }(x, value).extMsg;
    }

    function multiplication(int value) public view {
        optional(uint256) none;
        ICalculator(addrCalculator).multiplication{
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(printResult),
            onErrorId: tvm.functionId(onError)
        }(x, value).extMsg;
    }

    function division(int value) public view {
        optional(uint256) none;
        ICalculator(addrCalculator).division{
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(printResult),
            onErrorId: tvm.functionId(onError)
        }(x, value).extMsg;
    }

    // Функция result() выводит результат операции
    // и опять запускает mainMenu
    // Круг замкнулся
    function printResult(int res) public view{
        Terminal.print(tvm.functionId(mainMenu), format("Result: {}", res));
    }

    // выход из дебота
    function exit(uint32 index)public view{
        index;
        Terminal.print(0, "Goodbay!");
    }

    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
    }
}
