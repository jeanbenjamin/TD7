pragma solidity >=0.4.22 <0.6.0;


import "./openzeppelin_data/Address.sol";
import "./openzeppelin_data/Counters.sol";

contract ticketingSystem{
	using Address for address;
    using Counters for Counters.Counter;
	
	
	struct artist{
	address owner;
	bytes32 name;
	uint artistCategory;
	uint totalTicketSold;
	bool hasBeenModified;
	}
	
	mapping(uint => artist) public artistsRegister;
	uint public nextArtistIndex=1;
	
	event createdAnArtist(uint objectNumber);
	
	function createArtist(bytes32 _name, uint _cat) public {
		
		artistsRegister[nextArtistIndex].owner=msg.sender;
		artistsRegister[nextArtistIndex].name=_name;
		artistsRegister[nextArtistIndex].artistCategory=_cat;
	    artistsRegister[nextArtistIndex].hasBeenModified=false;
		artistsRegister[nextArtistIndex].totalTicketSold=0;
		nextArtistIndex = nextArtistIndex + 1;
		
		emit createdAnArtist(nextArtistIndex);
	}
	
	function modifyArtist(uint index, bytes32 _name, uint _cat, address _address) public {
		require(artistsRegister[index].owner==msg.sender);
		artistsRegister[index].name=_name;
		artistsRegister[index].artistCategory=_cat;	
		artistsRegister[index].owner=_address;
		artistsRegister[index].hasBeenModified=true;	
	}
	
	struct venue{
	address owner;
	bytes32 name;
	uint capacity;
	uint standardComission;
	uint cashVenue;
	bool available;
	}
	
	mapping(uint => venue) public venuesRegister;
	uint public nextVenueIndex=1;
	
	function createVenue(bytes32 _name, uint _capacity, uint _comission) public {
	
		venuesRegister[nextVenueIndex].owner=msg.sender;
		venuesRegister[nextVenueIndex].name=_name;
		venuesRegister[nextVenueIndex].capacity=_capacity;
		venuesRegister[nextVenueIndex].standardComission=_comission;
		venuesRegister[nextVenueIndex].cashVenue=0;
		venuesRegister[nextVenueIndex].available=false;
		nextVenueIndex = nextVenueIndex + 1;
	}
	
	function modifyVenue(uint index, bytes32 _name, uint _capacity, uint _comission, address _address) public{
		require(venuesRegister[index].owner==msg.sender);
		venuesRegister[index].name=_name;
		venuesRegister[index].capacity=_capacity;
		venuesRegister[index].standardComission=_comission;	
		venuesRegister[index].owner=_address;	
	}
	
	struct concert{
	uint artistId;		//index de l'objet
	uint venueId;
	uint concertDate;
	uint ticketPrice;
	bool validatedByArtist;
	bool validatedByVenue;
	uint totalSoldTicket;
	uint totalMoneyCollected;
	}
	
	mapping(uint => concert) public concertsRegister;
	uint public nextConcertIndex=1;
	
	
	  function createConcert(uint _artistId, uint _venueId, uint _concertDate, uint _ticketPrice)
  public
  returns (uint concertNumber)
  {
    require(_concertDate >= now);
    require(artistsRegister[_artistId].owner != address(0));
    require(venuesRegister[_venueId].owner != address(0));
	
    concertsRegister[nextConcertIndex].concertDate = _concertDate;
    concertsRegister[nextConcertIndex].artistId = _artistId;
    concertsRegister[nextConcertIndex].venueId = _venueId;
    concertsRegister[nextConcertIndex].ticketPrice = _ticketPrice;
	concertsRegister[nextConcertIndex].totalSoldTicket=0;
	concertsRegister[nextConcertIndex].totalMoneyCollected=0;
    validateConcert(nextConcertIndex);
    concertNumber = nextConcertIndex;
    nextConcertIndex +=1;
  }
  
  function validateConcert(uint _concertId)
  public
  {
    require(concertsRegister[_concertId].concertDate >= now);
    if (venuesRegister[concertsRegister[_concertId].venueId].owner == msg.sender)
    {
      concertsRegister[_concertId].validatedByVenue = true;
    }
    if (artistsRegister[concertsRegister[_concertId].artistId].owner == msg.sender)
    {
      concertsRegister[_concertId].validatedByArtist = true;
    }
  }
 
	
	struct ticket{
	address payable owner;
	uint concertDate;
	uint artistId;			
	uint venueId;
	bool isAvailable;	
	bool isAvailableForSale;
	}
	
	
	mapping(uint => ticket) public ticketsRegister;
	uint public nextTicketIndex=1;
	
	function emitTicket(uint _concertId, address payable _ticketOwner) public
	{
		require(artistsRegister[concertsRegister[_concertId].artistId].owner == msg.sender);
	//	require(concertsRegister[_concertId].validatedByArtist==true);
		require(concertsRegister[_concertId].validatedByVenue==true);
		require(venuesRegister[concertsRegister[_concertId].venueId].capacity>=nextTicketIndex);
		
		ticketsRegister[nextTicketIndex].owner=_ticketOwner;
		ticketsRegister[nextTicketIndex].concertDate=concertsRegister[_concertId].concertDate;
		ticketsRegister[nextTicketIndex].artistId=concertsRegister[_concertId].artistId;
		ticketsRegister[nextTicketIndex].venueId=concertsRegister[_concertId].venueId;
		ticketsRegister[nextTicketIndex].isAvailable=true;
		ticketsRegister[nextTicketIndex].isAvailableForSale=false;
		nextTicketIndex = nextTicketIndex + 1;
		concertsRegister[_concertId].totalSoldTicket+=1;	
	}
	
	function useTicket(uint _ticketId) public {
		require(ticketsRegister[_ticketId].owner!=address(0));
		require(ticketsRegister[_ticketId].owner==msg.sender);
		require(ticketsRegister[_ticketId].concertDate == now);			
		require(concertsRegister[ticketsRegister[_ticketId].venueId].validatedByVenue == true);
		ticketsRegister[_ticketId].isAvailable=false;
		ticketsRegister[_ticketId].owner=address(0);
		//delete ticketsRegister[_ticketId];
	}
	
	function buyTicket(uint _concertId) public payable
	{
		require(concertsRegister[_concertId].venueId!=0);
		emitTicket(_concertId,msg.sender);
		//ticketsRegister[_concertId].owner=msg.sender;		
		concertsRegister[_concertId].totalMoneyCollected+=concertsRegister[_concertId].ticketPrice;
	}
	
	function transferTicket(uint _ticketId, address payable _newOwner) public
	{
		require(ticketsRegister[_ticketId].owner!=address(0));
		require(ticketsRegister[_ticketId].isAvailable==true);
		require(ticketsRegister[_ticketId].owner!=_newOwner);
		ticketsRegister[_ticketId].owner=_newOwner;	
	}
	
	function cashOutConcert(uint _concertId, address payable _cashOutAddress) public
	{
		
		require(concertsRegister[_concertId].concertDate>now);
		//uint cashVenue=venuesRegister[concertsRegister[_concertId].venueId].standardComission;
		artistsRegister[concertsRegister[_concertId].artistId].totalTicketSold=concertsRegister[_concertId].totalMoneyCollected - venuesRegister[concertsRegister[_concertId].venueId].standardComission;
		venuesRegister[concertsRegister[_concertId].venueId].cashVenue+=venuesRegister[concertsRegister[_concertId].venueId].standardComission;
		concertsRegister[_concertId].totalMoneyCollected=0;		
	}
}

