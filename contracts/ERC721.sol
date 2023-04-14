pragma solidity 0.7.4;
//SPDX-License-Identifier: UNLICENSED

/*
contract Admin {
    address public admin;
    event AdminChanged(address oldAdmin, address newAdmin);
    function changeAdmin(address _admin) external {
        require(msg.sender == admin, "only admin can change admin");
        emit AdminChanged(admin, _admin);
        admin = _admin;
    }
}

contract SuperOperators is Admin {
    mapping(address => bool) internal mSuperOperators;
    event SuperOperator(address superOperator, bool enabled);
    function setSuperOperator(address _superOperator, bool _enabled) external {
        require(
            msg.sender == admin,
            "only admin is allowed to add super operators"
        );
        mSuperOperators[_superOperator] = _enabled;
        emit SuperOperator(_superOperator, _enabled);
    }
    function isSuperOperator(address who) public view returns (bool) {
        return mSuperOperators[who];
    }
}

interface ERC1155 {
    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);
    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    event URI(string _value, uint256 indexed _id);
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external;
    function balanceOf(address _owner, uint256 _id) external view returns (uint256);
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);
    function setApprovalForAll(address _operator, bool _approved) external;
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

interface ERC1155TokenReceiver {
    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns (bytes4);
    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns (bytes4);
}



*/

library AddressUtils {
    function isContract(address addr) internal view returns (bool) {
        // for accounts without code, i.e. `keccak256('')`:
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        bytes32 codehash;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            codehash := extcodehash(addr)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeMath {
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

interface ERC165 {
    /**
   * @notice Query if a contract implements an interface
   * @param _interfaceId The interface identifier, as specified in ERC-165
   * @dev Interface identification is specified in ERC-165. This function
   * uses less than 30,000 gas.
   */
    function supportsInterface(bytes4 _interfaceId)
        external
        view
        returns (bool);
}

interface ERC721Events {
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function mint(address account, uint256 amount) external;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface Uniswap{
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function removeLiquidityETH( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function WETH() external pure returns (address);
}

interface IERC721 {
    function balanceOf(address _owner) external view returns (uint256 _balance);
    function ownerOf(uint256 _tokenId) external view returns (address _owner);
    //   function exists(uint256 _tokenId) external view returns (bool _exists);


    function approve(address _to, uint256 _tokenId) external;
    function getApproved(uint256 _tokenId)
        external
        view
        returns (address _operator);

    function setApprovalForAll(address _operator, bool _approved) external;
    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool);

    function transferFrom(address _from, address _to, uint256 _tokenId)
        external;


    function safeTransferFrom(address _from, address _to, uint256 _tokenId)
        external;

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    ) external;

}
/*
interface ERC721TokenReceiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface ERC721Enumerable {
    /// @notice Count NFTs tracked by this contract
    /// @return A count of valid NFTs tracked by this contract, where each one of
    ///  them has an assigned and queryable owner not equal to the zero address
    function totalSupply() external view returns (uint256);

    /// @notice Enumerate valid NFTs
    /// @dev Throws if `_index` >= `totalSupply()`.
    /// @param _index A counter less than `totalSupply()`
    /// @return The token identifier for the `_index`th NFT,
    ///  (sort order not specified)
    function tokenByIndex(uint256 _index) external view returns (uint256);

    /// @notice Enumerate NFTs assigned to an owner
    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid NFTs.
    /// @param _owner An address where we are interested in NFTs owned by them
    /// @param _index A counter less than `balanceOf(_owner)`
    /// @return The token identifier for the `_index`th NFT assigned to `_owner`,
    ///   (sort order not specified)
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}
*/

contract LiquidCD is IERC721, ERC721Events {
    // LIBRARIES /////////////////////////////////////////////////////////////////////////
    using AddressUtils for address;
    using SafeMath for uint256;
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
//    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
//    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
//    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    
    Token[] tokens;
    
    struct Token{
        uint timeStamp;
        uint maturity;
        address tokenA;
        address tokenB;
        uint LP;
        uint tokenABonus;
        uint tokenBBonus;
    }
    
    mapping (address => uint256) public ownershipTokenCount;
    mapping (uint256 => address) public tokenIndexToOwner;
    mapping (uint256 => address) public tokenIndexToApproved;
    
    mapping (address => mapping(address => uint)) public poolBalance;
    mapping (address => mapping(address => uint)) public penaltyBalance;
    
    mapping(address => uint)  public promisedTokenBonus;
    mapping (address => mapping(address => bool)) public operatorApprovals;
    
    //Uniswap stuff
    uint private maturity = 2 hours;
    uint constant INF = 33136721748;
    address public owner = 0x859DF625A5B008539641fD78eB51dF03C8e17091;
    uint internal COIN = 10**18;
    
    address internal devAddress = 0xe9F03242598738c3d3a40E0521A13400D926D66A;
    address internal UNIROUTER         = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address internal  UNIFACTORY           = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address internal  WETHAddress       = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
    ////
    event CreateCD(address user, address tokenA, address tokenB, uint amountA, uint amountB, uint _LP);
    event CDdeath(address _userAddress, uint totalLP, uint bonusLP, uint penaltyLP);
    
    function addLiquidity(address tokenA, address tokenB, uint _hours, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, uint deadline) public {
        require(tokenA != tokenB || tokenA != address(0) || tokenB != address(0));
        _addLiquidity(tokenA, tokenB, _hours, amountADesired, amountBDesired, amountAMin, amountBMin, deadline);
    }
    
    function addLiquidityETH(address tokenA, uint _hours, uint amountADesired, uint amountAMin, uint amountBMin, uint deadline) public payable {
        require(tokenA != address(0));
        _addLiquidityETH(tokenA, _hours, amountADesired, amountAMin, amountBMin, deadline);
    }
    
    receive() external payable {

       if(msg.sender != UNIROUTER){
            //uint ethAmount = IERC20(WETHAddress).balanceOf(poolAddress); //Eth in uniswap
           // uint tokenAmount = IERC20(tokenAddress1).balanceOf(poolAddress); //token in uniswap
            //uint amountBDesired = msg.value;
            //uint amountADesired = ((msg.value).mul(tokenAmount)).div(ethAmount); 
            //addLiquidity(amountADesired, amountBDesired, amountADesired, amountBDesired, INF);
       }
    }
    
    function _addLiquidity(address tokenA, address tokenB, uint _hours, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, uint deadline) internal {//_tokenStake is wrong number for subcontract
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountADesired); //send tokens to this contract
        IERC20(tokenA).approve(UNIROUTER, amountADesired); //allow unirouter to send these tokens
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountBDesired);
        IERC20(tokenB).approve(UNIROUTER, amountBDesired); //allow unirouter to send these tokens
        uint tokenABonus = 0;
        uint tokenBBonus = 0;
        uint _newCD = mint(tokenA, tokenB, _hours, 0, tokenABonus, tokenBBonus);  
        (,, uint liquidity) = Uniswap(UNIROUTER).addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, address(this), deadline);//add liquidity
        if(IERC20(tokenA).balanceOf(address(this)) >= _hours.mul(COIN).div(100).add(promisedTokenBonus[tokenA])){
            tokenABonus = _bonusTokens(tokenA, tokenB, _hours, liquidity);
            tokens[_newCD].tokenABonus = tokenABonus;
            promisedTokenBonus[tokenA] = promisedTokenBonus[tokenA].add(tokenABonus);
        }
        if(IERC20(tokenB).balanceOf(address(this)) >= _hours.mul(COIN).div(100).add(promisedTokenBonus[tokenB])){
            tokenBBonus = _bonusTokens(tokenB, tokenA, _hours, liquidity);
            tokens[_newCD].tokenBBonus = tokenBBonus;
            promisedTokenBonus[tokenB] = promisedTokenBonus[tokenB].add(tokenBBonus);
        }
        poolBalance[tokenA][tokenB] = poolBalance[tokenA][tokenB].add(liquidity);
        poolBalance[tokenB][tokenA] = poolBalance[tokenB][tokenA].add(liquidity);//in reverse
        tokens[_newCD].LP = liquidity;
        emit CreateCD(msg.sender, tokenA, tokenB, amountADesired, amountBDesired, liquidity);
    }
    

    
    function _addLiquidityETH(address tokenA, uint _hours, uint amountADesired, uint amountAMin, uint amountBMin, uint deadline) internal {
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountADesired); //send tokens to this contract
        IERC20(tokenA).approve(UNIROUTER, amountADesired); //allow unirouter to send these tokens
        uint tokenABonus = 0;
        uint _newCD = mint(tokenA, WETHAddress, _hours, 0, 0, 0);  
        (,,uint liquidity) = Uniswap(UNIROUTER).addLiquidityETH{ value: msg.value }(tokenA, amountADesired, amountAMin, amountBMin, address(this), deadline);//add liquidity
        if(IERC20(tokenA).balanceOf(address(this)) >= _hours.mul(COIN).div(100).add(promisedTokenBonus[tokenA])){
            tokenABonus = _bonusTokens(tokenA,  WETHAddress,  _hours, liquidity);
            tokens[_newCD].tokenABonus = tokenABonus;
            promisedTokenBonus[tokenA] = promisedTokenBonus[tokenA].add(tokenABonus);
        }
        poolBalance[tokenA][WETHAddress] = poolBalance[tokenA][WETHAddress].add(liquidity);
        poolBalance[WETHAddress][tokenA] = poolBalance[WETHAddress][tokenA].add(liquidity);
        tokens[_newCD].LP = liquidity;
        emit CreateCD(msg.sender, tokenA, WETHAddress, amountADesired, msg.value, liquidity);
    }
    
    function _bonusTokens(address tokenA, address tokenB, uint _hours, uint liquidity) internal view returns(uint _bonus){
        _bonus = _hours.mul(COIN).mul(_getPercent(liquidity, poolBalance[tokenA][tokenB])).div(100);
    }
  
     
    function _getPercent(uint part, uint whole) private pure returns(uint percent) {
        uint numerator = part.mul(1000);
        require(numerator > part); // overflow. Should use SafeMath throughout if this was a real implementation. 
        uint temp = (numerator.div(whole)).add(5); // proper rounding up
        return temp.div(10);
    }
    
    function getLPbalance(uint _tokenId) public view returns (uint _balance){
        uint _amount = tokens[_tokenId].LP;
        uint penalty = getPenalty(_tokenId);
        uint bonus = getBonus(_tokenId);
        _balance = _amount.sub(penalty).add(bonus);
    }
    
    function getAge(uint _tokenId) public view returns (uint _time) {
        _time = block.timestamp.sub(tokens[_tokenId].timeStamp);
    }    
    
    function getPenalty(uint _tokenId) public view returns(uint _penalty){
        uint _percentage = _getPercent(getAge(_tokenId), tokens[_tokenId].maturity);
        uint grossAmount = tokens[_tokenId].LP;
        if(_percentage >= 100) {
            _penalty = 0;
        } else {
            _penalty = grossAmount.sub(grossAmount.mul(_percentage).div(100)).div(2);//percentage of the LP based on % of maturity. Div by 2 so it isn't as steep.// the most you can lose is half
        }
        
    }
    
    function getBonus(uint _tokenId) public view returns(uint _bonus){
        uint _percentage = _getPercent(getAge(_tokenId), tokens[_tokenId].maturity);
        uint grossAmount = tokens[_tokenId].LP;
        if(_percentage >= 100) {
            _bonus = penaltyBalance[tokens[_tokenId].tokenA][tokens[_tokenId].tokenB].mul(_getPercent(grossAmount, poolBalance[tokens[_tokenId].tokenA][tokens[_tokenId].tokenB])).div(100);//percentage of LP owned and LP owned by this pool multiplied by bonus available
            _bonus = _bonus.div(8760/*hours in a year*/).mul(tokens[_tokenId].maturity.div(1 hours));//hours of maturity
        } else {
            _bonus = 0;
        }
    }
    
    function transferLP(uint _tokenId)public {
        require(msg.sender == tokenIndexToOwner[_tokenId]);
        delete tokenIndexToOwner[_tokenId];
        ownershipTokenCount[msg.sender] = ownershipTokenCount[msg.sender].sub(1);
        address poolAddress = Uniswap(UNIFACTORY).getPair(tokens[_tokenId].tokenA, tokens[_tokenId].tokenB);//get pool address
        uint _amount = tokens[_tokenId].LP;
        uint penalty = getPenalty(_tokenId);
        uint bonus = getBonus(_tokenId);
        address tokenA = tokens[_tokenId].tokenA;
        address tokenB = tokens[_tokenId].tokenB;
        uint tokenABonus = tokens[_tokenId].tokenABonus;
        uint tokenBBonus = tokens[_tokenId].tokenBBonus;
        delete tokens[_tokenId];
        poolBalance[tokenA][tokenB] = poolBalance[tokenA][tokenB].sub(_amount);
        poolBalance[tokenB][tokenA] = poolBalance[tokenB][tokenA].sub(_amount);//in reverse
        penaltyBalance[tokenA][tokenB] = penaltyBalance[tokenA][tokenB].add(penalty);
        penaltyBalance[tokenB][tokenA] = penaltyBalance[tokenB][tokenA].add(penalty);
        penaltyBalance[tokenA][tokenB] = penaltyBalance[tokenA][tokenB].sub(bonus);
        penaltyBalance[tokenB][tokenA] = penaltyBalance[tokenB][tokenA].sub(bonus);
        //promisedTokenBonus
        IERC20(poolAddress).transfer(msg.sender, _amount.sub(penalty).add(bonus));
        if(penalty == 0) {
            if(promisedTokenBonus[tokenA] >= tokenABonus){
                IERC20(tokenA).transfer(msg.sender, tokenABonus);//transfer any token bonus
            }
            if(promisedTokenBonus[tokenB] >= tokenBBonus){
                IERC20(tokenB).transfer(msg.sender, tokenBBonus);//transfer any token bonux
            }
        }
        promisedTokenBonus[tokenA] = promisedTokenBonus[tokenA].sub(tokenABonus);
        promisedTokenBonus[tokenB] = promisedTokenBonus[tokenB].sub(tokenBBonus);
        emit CDdeath(msg.sender, _amount, bonus, penalty);
    }    
    
    
    function mint(address _tokenA, address _tokenB, uint _hours, uint _LP, uint _tokenABonus, uint _tokenBBonus) internal returns (uint tokenId){
        tokenId = tokens.length;
        Token memory _token = Token({
            timeStamp: block.timestamp,
            maturity: _hours * 1 hours,
            tokenA: _tokenA,
            tokenB: _tokenB,
            LP: _LP,
            tokenABonus: _tokenABonus,
            tokenBBonus:_tokenBBonus
        });
        tokenIndexToOwner[tokenId] = msg.sender; 
        ownershipTokenCount[msg.sender] = ownershipTokenCount[msg.sender].add(1);
        tokens.push(_token);
    }
    
    function getToken(uint _tokenId) public view returns ( uint _timeStamp, uint _maturity, address _tokenA, address _tokenB, uint _LP, uint tokenABonus, uint tokenBBonus){
        Token storage _token = tokens[_tokenId];
        _timeStamp = _token.timeStamp;
        _maturity = _token.maturity;
        _tokenA = _token.tokenA;
        _tokenB = _token.tokenB;
        _LP = _token.LP;
        tokenABonus = _token.tokenABonus;
        tokenBBonus = _token.tokenBBonus;
    }
   
    function ownerOf(uint256 _tokenId) external view override returns (address _owner){
        _owner = tokenIndexToOwner[_tokenId];
    }
 
    function exists(uint256 _tokenId) external view returns (bool _exists){
        if(tokenIndexToOwner[_tokenId] == address(0)) {
            _exists = false;
        } else {
            _exists = true;
        }
    }

    function approve(address _to, uint256 _tokenId) external override{
        // Only an owner can grant transfer approval.
        require(tokenIndexToOwner[_tokenId] == msg.sender);

        // Register the approval (replacing any previous approval).
        tokenIndexToApproved[_tokenId] = _to;

        // Emit approval event.
        emit Approval(msg.sender, _to, _tokenId);
    }

    function getApproved(uint256 _tokenId) external view override returns (address _operator){
        _operator = tokenIndexToApproved[_tokenId];
    }
    
    function setApprovalForAll(address _to, bool _approved) external override{
        require(_to != msg.sender);
        operatorApprovals[msg.sender][_to] = _approved;
        emit ApprovalForAll(msg.sender, _to, _approved);
    }
    
    function isApprovedForAll(address _owner, address _to) external view override returns (bool){
        return operatorApprovals[_owner][_to];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external override{
        require(_to != address(0) || _from != address(0));
        require(tokenIndexToApproved[_tokenId] == msg.sender || operatorApprovals[_from][msg.sender] == true || tokenIndexToOwner[_tokenId] == msg.sender);
        _transferFrom(_from, _to, _tokenId);
    }
    
    function _transferFrom(address _from, address _to, uint256 _tokenId) internal {
        tokenIndexToOwner[_tokenId] = _to;
        ownershipTokenCount[_from] = ownershipTokenCount[_from].sub(1);
        ownershipTokenCount[_to] = ownershipTokenCount[_to].add(1);
        delete tokenIndexToApproved[_tokenId];
    }
    
    function transfer(address _to, uint256 _tokenId) external{
        require(tokenIndexToOwner[_tokenId] == msg.sender);
        tokenIndexToOwner[_tokenId] = _to;
        ownershipTokenCount[msg.sender] = ownershipTokenCount[msg.sender].sub(1);
        ownershipTokenCount[_to] = ownershipTokenCount[_to].add(1);
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) external override{
        require(AddressUtils.isContract(_to) == false);
        require(_to != address(0) || _from != address(0));
        require(tokenIndexToApproved[_tokenId] == msg.sender || operatorApprovals[_from][msg.sender] == true || tokenIndexToOwner[_tokenId] == msg.sender);
        _transferFrom(_from, _to, _tokenId);
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external override{
        require(AddressUtils.isContract(_to) == false);
        require(_to != address(0) || _from != address(0));
        require(tokenIndexToApproved[_tokenId] == msg.sender || operatorApprovals[_from][msg.sender] == true || tokenIndexToOwner[_tokenId] == msg.sender);
        _transferFrom(_from, _to, _tokenId);
    }

    function totalSupply() external view returns (uint _total){
        _total = tokens.length;
    }

    function balanceOf(address _owner) public view override returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    function tokensOfOwner(address _owner) external view returns(uint256[] memory ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalTokens = tokens.length;
            uint256 resultIndex = 0;
            // We count on the fact that all tokens have IDs starting at 1 and increasing
            // sequentially up to the totalCat count.
            uint256 tokenId;

            for (tokenId = 1; tokenId <= totalTokens; tokenId++) {
                if (tokenIndexToOwner[tokenId] == _owner) {
                    result[resultIndex] = tokenId;
                    resultIndex++;
                }
            }

            return result;
        }
    }



}
