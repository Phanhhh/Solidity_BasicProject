// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract Lottery {
    
    // declaring the state variable
    // declaring dynamic array of type payable address for players
    address payable[] public players;

    // declaring manager address
    address public manager;


    // declaring the constructor
    constructor(){
        // initializing the owner to the adddess manager that deploys the contract
        manager = msg.sender;

        // the manager is automatically added to the lottery without sending any ether
        players.push(payable(manager));
    }

    // declaring the receive() function that is necessary to receive ETH to contract balance
    receive() external payable { 
        // each players sends exactly 0.1 ETH for joining Lottery
        require(msg.value == 0.1 ether, "You need to transfer only 0.1 ETH to join the lottery");
        // every one can join the lottery execpt manager
        require(msg.sender != manager, "You are manager. You cannot join the lottery");

        // appending the player to the players array
        players.push(payable(msg.sender));
    }

    // get the contract's balance in wei
    function getBalance() public view returns(uint) {
        // only the manager is allowed to get balance
        require(msg.sender == manager, "You are not a manager. Only Manager can get contract balance!");
        return address(this).balance;
    }

    // helper fucntion that returns a big random integer
    function random() internal view returns(uint) {
        //using keccak256 with
        return uint(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, players.length)));
    }

    // function to select the winner
    function pickWinner() public {
        // // Only manager can pick a winner if there are at least 3players in the lottery
        // require (msg.sender == manager, "You are not a manager. Only Manager can call to pick random Winner!");
        
        // Everyone can trigger to pick the winner
        require(players.length >= 10, "The players have to greater than 10 people");

        uint r = random();
        address payable winner;

        // computing a random index of the players array => choose the random winner
        uint index = r % players.length;

        // this is the winner
        winner = players[index];

        // a fee 10% of the lottery funds to manager
        // winner get 90% of the lettery funds
        uint managerPrize = (getBalance() * 10)/100;
        uint winnerPrize = (getBalance() * 90)/100;
        
        // transfering 10% contract's balance to the manager address
        payable(manager).transfer(managerPrize);

        // transfering 90% contract's balance to the winner address
        winner.transfer(winnerPrize);

        // resetting the lottery contract for the next round
        players = new address payable[] (0);
    }
}

