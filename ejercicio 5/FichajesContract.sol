// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FichajeFutbol {
    
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    struct Fichaje {
        uint id;
        string jugadorNombre;
        uint jugadorEdad;
        string clubOrigen;
        string clubDestino;
        uint256 valorTransferencia;
        uint256 fechaFichaje;       
        bool aprobado;
    }

    uint public totalFichajes;
    mapping(uint => Fichaje) public fichajes;

    event FichajeRegistrado(
        uint id,
        string jugadorNombre,
        string clubOrigen,
        string clubDestino,
        uint256 valorTransferencia,
        uint256 fechaFichaje
    );

    event FichajeAprobado(uint id);

    modifier soloOwner() {
        require(msg.sender == owner, "No tienes permisos");
        _;
    }

    function registrarFichaje(
        string memory _jugadorNombre,
        uint _jugadorEdad,
        string memory _clubOrigen,
        string memory _clubDestino,
        uint256 _valorTransferencia
    ) public soloOwner {
        require(_jugadorEdad >= 13 && _jugadorEdad <= 50, "Edad invalida, introduzca un valor entre 13 y 50");
        require(_valorTransferencia > 0, "El valor debe ser positivo");
        require(bytes(_jugadorNombre).length > 0, "Nombre requerido");
        require(bytes(_clubOrigen).length > 0, "Club origen requerido");
        require(bytes(_clubDestino).length > 0, "Club destino requerido");

        totalFichajes++;

        fichajes[totalFichajes] = Fichaje(
            totalFichajes,
            _jugadorNombre,
            _jugadorEdad,
            _clubOrigen,
            _clubDestino,
            _valorTransferencia,
            block.timestamp,
            false
        );

        emit FichajeRegistrado(
            totalFichajes,
            _jugadorNombre,
            _clubOrigen,
            _clubDestino,
            _valorTransferencia,
            block.timestamp
        );
    }

    function aprobarFichaje(uint _id) public soloOwner {
        require(_id <= totalFichajes, "Fichaje no existe");
        fichajes[_id].aprobado = true;

        emit FichajeAprobado(_id);
    }

    function obtenerFichaje(uint _id) public view returns (
        string memory jugadorNombre,
        uint jugadorEdad,
        string memory clubOrigen,
        string memory clubDestino,
        uint256 valorTransferencia,
        uint256 fechaFichaje,
        bool aprobado
    ) {
        require(_id <= totalFichajes, "Fichaje no encontrado");

        Fichaje memory f = fichajes[_id];
        return (
            f.jugadorNombre,
            f.jugadorEdad,
            f.clubOrigen,
            f.clubDestino,
            f.valorTransferencia,
            f.fechaFichaje,
            f.aprobado
        );
    }
}
