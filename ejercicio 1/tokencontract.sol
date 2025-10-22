// SPDX-License-Identifier: Unlicenced
pragma solidity 0.8.30;

contract TokenContract {

    address public owner;
    uint256 public constant TOKEN_PRICE = 5 ether; 
    
    struct Receivers {
        string name;
        uint256 tokens;
    }
    
    mapping(address => Receivers) public users;
    
    event TokensPurchased(address indexed buyer, uint256 amount, uint256 cost);
    event EtherWithdrawn(address indexed owner, uint256 amount);

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(){
        owner = msg.sender;
        users[owner].tokens = 100;
    }

    function double(uint _value) public pure returns (uint){
        return _value * 2;
    }

    function register(string memory _name) public {
        users[msg.sender].name = _name;
    }

    function giveToken(address _receiver, uint256 _amount) onlyOwner public {
        require(users[owner].tokens >= _amount, "Owner doesn't have enough tokens");
        users[owner].tokens -= _amount;
        users[_receiver].tokens += _amount;
    }
    
    // Función para comprar tokens con Ether
    function buyTokens(uint256 _amount) public payable {
        require(_amount > 0, "Amount must be greater than 0");
        require(users[owner].tokens >= _amount, "Owner doesn't have enough tokens to sell");
        
        uint256 requiredEther = _amount * TOKEN_PRICE;
        require(msg.value >= requiredEther, "Insufficient Ether sent");
        
        // Transferir tokens del owner al comprador
        users[owner].tokens -= _amount;
        users[msg.sender].tokens += _amount;

        emit TokensPurchased(msg.sender, _amount, requiredEther);
        
        // Reembolsar Ether excedente si el usuario envió más de lo necesario
        if (msg.value > requiredEther) {
            payable(msg.sender).transfer(msg.value - requiredEther);
        }
    }
    
    // Función para que el owner pueda retirar el Ether del contrato
    function withdrawEther() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No Ether to withdraw");
        
        payable(owner).transfer(contractBalance);
        emit EtherWithdrawn(owner, contractBalance);
    }
    
    // Función para ver el balance de Ether del contrato
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    // Función para calcular el costo de comprar cierta cantidad de tokens
    function calculateCost(uint256 _amount) public pure returns (uint256) {
        return _amount * TOKEN_PRICE;
    }
    
    // Función para obtener información del usuario
    function getUserInfo(address _user) public view returns (string memory, uint256) {
        return (users[_user].name, users[_user].tokens);
    }
}