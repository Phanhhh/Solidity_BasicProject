// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract AuctionCreator{
    Auction[] public auctions;

    // function create Auction and who created Auction is owner of this auction
    function createAuction() public{
        Auction newAuction = new Auction(msg.sender);
        auctions.push(newAuction);
    }
}


contract Auction{
    address payable public owner;
    uint public startBlock;
    uint public endBlock;
    string public ipfsHash;

    enum State {Started, Running, Ended, Canceled}
    State public auctionState;

    uint public highestBindingBid;
    address payable public highestBidder;

    mapping (address => uint) public bids;
    uint bidIncrement;

    constructor(address eoa) {
        owner = payable(eoa);
        auctionState = State.Running;
        startBlock = block.number;
        endBlock = startBlock + 40320; // mean endBlock after 1 week of startBlock (15s for a block)
        ipfsHash = "";
        bidIncrement = 1 ether;
    }


    modifier notOwner(){
        require(msg.sender != owner, "You are onwer.");
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "You are not owner.");
        _;
    }

    modifier afterStart(){
        require(block.number >= startBlock);
        _;
    }

    modifier beforeEnd(){
        require(block.number <= endBlock);
        _;
    }

    // helper function min
    function min(uint a, uint b) pure internal returns(uint) {
        if(a<=b){
            return a;
        }
        else {
            return b;
        }
    }

    // function for cancelAuction
    function cancelAuction() public onlyOwner {
        auctionState = State.Canceled;
    }

    // function allow everyone to place a bid, not the owner
    function placeBid() public payable notOwner afterStart beforeEnd{
        require(auctionState == State.Running, "The auction is not running.");
        require(msg.value >= 1 ether, "Mininum bid must be greater than or qeual to 100");

        uint currentBid = bids[msg.sender] + msg.value;
        require(currentBid > highestBindingBid, "Your bid have to greater than current highest bid");

        bids[msg.sender] = currentBid;

        if(currentBid <= bids[highestBidder]){
            highestBindingBid = currentBid;
        }
        else{
            highestBindingBid = currentBid;
            highestBidder = payable(msg.sender); // update new highestBidder
        }
    }

    // function finalization the auction
    function finalizeAuction() public {
        require(auctionState == State.Canceled || block.number > endBlock, "The auction is still happen.");
        require(msg.sender == owner || bids[msg.sender] > 0, "Only the owner or bidder can call this function.");

        address payable recipient;
        uint value;

        if (auctionState == State.Canceled) { // the auction was canceled
            recipient == payable(msg.sender);
            value = bids[msg.sender];
        }
        else { // the auction is ended (not canceled)
            if(msg.sender == owner){ // this is the owner
                recipient = owner;
                value = highestBindingBid;
            }
            else{ // this is a bidder
                if (msg.sender == highestBidder){ // this is a highest bidder (the winner)
                    recipient = highestBidder;
                    value = highestBindingBid;
                }
                else{ // this is neither the owner nor the highest bidder
                    recipient = payable(msg.sender);
                    value = bids[msg.sender];
                }
            }
        }

        // resetting the bids value of recipient and they are not a bidder
        bids[recipient] = 0;

        // sends value to the recipient
        recipient.transfer(value);
    }
}