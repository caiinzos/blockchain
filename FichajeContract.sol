// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract FichajeContract {
    address public owner;
    uint256 public totalFichajes;
    
    struct Fichaje {
        uint256 id;
        string nombreJugador;
        uint256 edad;
        string clubOrigen;
        string clubDestino;
        uint256 valorTransferencia;
        uint256 fechaRegistro;
        bool aprobado;
        string ipfsHash;
        address subidoPor;
    }
    
    mapping(uint256 => Fichaje) public fichajes;
    mapping(address => bool) public clubsAutorizados;
    
    event FichajeRegistrado(uint256 indexed id, string nombreJugador);
    event FichajeAprobado(uint256 indexed id);
    event DocumentoSubido(uint256 indexed id, string ipfsHash);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el owner puede ejecutar esta funcion");
        _;
    }
    
    modifier onlyAutorizado() {
        require(msg.sender == owner || clubsAutorizados[msg.sender], "No autorizado");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        clubsAutorizados[msg.sender] = true;
    }
    
    function autorizarClub(address _club) external onlyOwner {
        clubsAutorizados[_club] = true;
    }
    
    function registrarFichaje(
        string memory _nombreJugador,
        uint256 _edad,
        string memory _clubOrigen,
        string memory _clubDestino,
        uint256 _valorTransferencia
    ) external onlyAutorizado {
        require(_edad >= 13 && _edad <= 50, "Edad no valida");
        require(_valorTransferencia > 0, "Valor debe ser mayor a 0");
        require(bytes(_nombreJugador).length > 0, "Nombre requerido");
        
        totalFichajes++;
        
        fichajes[totalFichajes] = Fichaje({
            id: totalFichajes,
            nombreJugador: _nombreJugador,
            edad: _edad,
            clubOrigen: _clubOrigen,
            clubDestino: _clubDestino,
            valorTransferencia: _valorTransferencia,
            fechaRegistro: block.timestamp,
            aprobado: false,
            ipfsHash: "",
            subidoPor: address(0)
        });
        
        emit FichajeRegistrado(totalFichajes, _nombreJugador);
    }
    
    function subirDocumentoFichaje(uint256 _id, string memory _ipfsHash) external onlyAutorizado {
        require(_id > 0 && _id <= totalFichajes, "ID no valido");
        require(bytes(_ipfsHash).length > 0, "Hash IPFS requerido");
        
        fichajes[_id].ipfsHash = _ipfsHash;
        fichajes[_id].subidoPor = msg.sender;
        
        emit DocumentoSubido(_id, _ipfsHash);
    }
    
    function aprobarFichaje(uint256 _id) external onlyOwner {
        require(_id > 0 && _id <= totalFichajes, "ID no valido");
        require(!fichajes[_id].aprobado, "Fichaje ya aprobado");
        
        fichajes[_id].aprobado = true;
        emit FichajeAprobado(_id);
    }
    
    function obtenerFichaje(uint256 _id) external view returns (
        string memory nombreJugador,
        uint256 edad,
        string memory clubOrigen,
        string memory clubDestino,
        uint256 valorTransferencia,
        uint256 fechaRegistro,
        bool aprobado,
        string memory ipfsHash,
        address subidoPor
    ) {
        require(_id > 0 && _id <= totalFichajes, "ID no valido");
        Fichaje memory f = fichajes[_id];
        return (
            f.nombreJugador,
            f.edad,
            f.clubOrigen,
            f.clubDestino,
            f.valorTransferencia,
            f.fechaRegistro,
            f.aprobado,
            f.ipfsHash,
            f.subidoPor
        );
    }
}