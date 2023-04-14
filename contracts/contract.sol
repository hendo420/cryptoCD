//"SPDX-License-Identifier: UNLICENSED"

pragma solidity 0.6.12;

contract CDfactory {
    using SafeMath for uint256;
    mapping (address => address) CDburners;
    uint public numberOfBurners = 0; 
    uint private maturity = 2 hours;
    address owner = 0x859DF625A5B008539641fD78eB51dF03C8e17091;
    
    address internal devAddress = 0xe9F03242598738c3d3a40E0521A13400D926D66A;
    address internal UNIROUTER         = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address internal  UNIFACTORY           = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address internal  WETHAddress       = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
    
    function getMaturity() external view returns(uint _maturity){
        _maturity = maturity;
    }

    function getDevAddress() external view returns(address _devAddress) {
        _devAddress = devAddress;
    }
    
    function getUniRouterAddress() external view returns(address _uniRouterAddress) {
        _uniRouterAddress = UNIROUTER;
    }
/*    
    function getUniFactoryAddress() external view returns(address _uniFactoryAddress) {
        _uniFactoryAddress = UNIFACTORY;
    }
    
    function getWETHAddress() external view returns(address _WETHAddress) {
        _WETHAddress = WETHAddress;
    }
*/   //give it both addresses, no reason it can't be just like the original
    function newCDburner(address _tokenAddress) public returns(address _newCD) {
        require(CDburners[_tokenAddress] == 0x0000000000000000000000000000000000000000);
        /*
        if(Uniswap(UNIFACTORY).getPair(_tokenAddress, WETHAddress) == address(0x0)) {
            Uniswap(UNIFACTORY).createPair(_tokenAddress, WETHAddress);
        }
        */
        CDburner copy = new CDburner(_tokenAddress, address(this), UNIFACTORY, UNIROUTER, WETHAddress, Uniswap(UNIFACTORY).getPair(_tokenAddress, WETHAddress));
        CDburners[_tokenAddress] = address(copy);
        numberOfBurners = numberOfBurners.add(1);
        _newCD = address(copy);
    }
    
    function setMaturity(uint _maturityInSeconds) public returns(bool) {
        require(msg.sender == owner);
        maturity = _maturityInSeconds;
    }
    
    function setOwner(address _newOwner) public returns(bool) {
        require(msg.sender == owner);
        owner = _newOwner;
    }
    
    function setDevAddress(address _newDev) public returns(bool) {
        require(msg.sender == devAddress);
        devAddress = _newDev;
    }
    
    function getCDburner(address _tokenAddress) public view returns(address _CDaddress){
        _CDaddress = CDburners[_tokenAddress];
    }
    
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;}

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");}

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;}

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;}

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");}

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;}

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");}

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;}
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
    function removeLiquidityETH( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function WETH() external pure returns (address);
}

contract CDburner {

    using SafeMath for uint256;
    uint constant INF = 33136721748;

    //uint public numberOfCDs = 0; 
    uint stackOfCDs = 0;
    
    uint public totalLPstaked = 0;

    address public tokenAddress;
    address public CDfactoryAddress;
    address public UniFactoryAddress;
    address public UniRouterAddress;
    address public WETHaddress;
    address public poolAddress;
    
    uint public ERC20reward = 100;
    uint internal COIN = 10**18;
    uint public changeTokenRewardFee = COIN.mul(1000);
    uint public upTokenVotes = 0;
    uint public downTokenVotes = 0;
    uint public LPreward = 100;
    uint public changeLPRewardFee = COIN.mul(1000);
    uint public upLPVotes = 0;
    uint public downLPVotes = 0;
    

    receive() external payable {

       if(msg.sender != CDfactory(CDfactoryAddress).getUniRouterAddress()){
           addLiquidity();
       }
    }

constructor(address _tokenAddress, address _CDfactoryAddress, address _UniFactoryAddress, address _UniRouterAddress, address _WETHaddress, address _poolAddress) public {
    tokenAddress = _tokenAddress;
    CDfactoryAddress = _CDfactoryAddress;
    UniRouterAddress = _UniRouterAddress;
    UniFactoryAddress = _UniFactoryAddress;
    WETHaddress = _WETHaddress;
    poolAddress = _poolAddress;
}

    mapping (address => mapping (address => address)) private CDs;
    
    
    event CreateCD(address _address, uint _ethAmount, uint _tokenStake, uint _originalLP);
    event CDdeath(address _userAddress, uint _lpAmount, bool _matured, uint _extra);
    
    
    function getTotalLPstaked() public view returns(uint _totalLPstaked) {
        _totalLPstaked = totalLPstaked;
    }
    
    function _newTrack(address _tokenAddress, address _userAddress)internal returns(address _newCD){
        //require(cdChanger[_tokenAddress][_userAddress] == 0x0000000000000000000000000000000000000000);
        ////require(_isAlive(getCD(_tokenAddress, _userAddress)) != true);
        CD copy = new CD(_tokenAddress, address(this), CDfactoryAddress, msg.sender, now, WETHaddress, UniFactoryAddress, poolAddress);
        CDs[_tokenAddress][_userAddress] = address(copy);
        stackOfCDs = stackOfCDs.add(1);
        _newCD = address(copy);
    }
    
    mapping (address => bool) public isAlive;
    
    function CDdeathReport(address _userAddress, uint _lpAmount, bool _matured) public {
        require(msg.sender == getCD(_userAddress));
        require(CDs[tokenAddress][_userAddress] != 0x0000000000000000000000000000000000000000);
        CDs[tokenAddress][_userAddress] = 0x0000000000000000000000000000000000000000;
        totalLPstaked = totalLPstaked.sub(_lpAmount);
        //numberOfCDs = numberOfCDs.sub(1);
        isAlive[_userAddress] = false;
        stackOfCDs = stackOfCDs.sub(1);
        if(_matured == true) {
            if(IERC20(poolAddress).balanceOf(address(this)) != 0){//if the balance of this contract isn't 0
                uint percent = _getPercent(IERC20(poolAddress).balanceOf(msg.sender), totalLPstaked);//get percent between what was just sent and the total LP of the pool
                uint _amount = _lpAmount.mul(percent).div(LPreward);//multiply by the percentage to get the extra to send
                
                if(IERC20(tokenAddress).balanceOf(address(this)) >= 100000) {
                    uint erc20amount = ((IERC20(tokenAddress).balanceOf(address(this))).mul(percent)).div(100);
                    IERC20(tokenAddress).transfer(_userAddress, erc20amount.div(ERC20reward));
                }
                
                if(IERC20(poolAddress).balanceOf(address(this)) >= _amount){//if the LP on the contract is enough to cover it
                    IERC20(poolAddress).transfer(_userAddress, _amount);//send extra LP to the new contract
                    totalLPstaked = totalLPstaked.sub(_amount);
                    emit CDdeath(_userAddress, _lpAmount, _matured, _amount);
                }
            }
        } else {
            emit CDdeath(_userAddress, _lpAmount, _matured, 0);
        }
        
    }
    
    
    

    
    function increaseERC20reward(uint _amount) public {
        require(IERC20(tokenAddress).allowance(msg.sender, tokenAddress) >= _amount);
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);
        upTokenVotes = upTokenVotes.add(_amount);
        if(upTokenVotes >= changeTokenRewardFee) {
            ERC20reward = ERC20reward.sub(1);
            upTokenVotes = 0;
            if(changeTokenRewardFee != 0) {
                changeTokenRewardFee = changeTokenRewardFee.add((changeTokenRewardFee.mul(15)).div(100));
            }
        }
    }
    
    function decreaseERC20reward(uint _amount) public {
        require(IERC20(tokenAddress).allowance(msg.sender, tokenAddress) >= _amount);
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);
        downTokenVotes = downTokenVotes.add(_amount);
        if(downTokenVotes >= changeTokenRewardFee) {
            ERC20reward = ERC20reward.add(1);
            downTokenVotes = 0;
                changeTokenRewardFee = changeTokenRewardFee.sub((changeTokenRewardFee.mul(15)).div(100));
        }
    }
    

    
    function increaseLPreward(uint _amount) public {
        require(IERC20(tokenAddress).allowance(msg.sender, tokenAddress) >= _amount);
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);
        upLPVotes = upLPVotes.add(_amount);
        if(upLPVotes >= changeLPRewardFee) {
            ERC20reward = ERC20reward.sub(1);
            upLPVotes = 0;
            changeLPRewardFee = changeLPRewardFee.add((changeTokenRewardFee.mul(10)).div(100));
        }
    }
    
    function decreaseLPreward(uint _amount) public {
        require(IERC20(tokenAddress).allowance(msg.sender, tokenAddress) >= _amount);
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);
        downLPVotes = downLPVotes.add(_amount);
        if(downLPVotes >= changeLPRewardFee) {
            ERC20reward = ERC20reward.add(1);
            downLPVotes = 0;
            if(changeLPRewardFee >= 1*COIN) {
                changeLPRewardFee = changeLPRewardFee.sub((changeTokenRewardFee.mul(10)).div(100));
            }
        }
    }

    function getCD(address _userAddress) public view returns(address _CDaddress){
        _CDaddress = CDs[tokenAddress][_userAddress];
    }
    
    function _isAlive(address _address) internal view returns (bool) {
        //return CD(_address).alive();
        return isAlive[_address];
    }
  
    function addLiquidity() public payable {
        require(msg.value != 0);//make sure the user sends ETH
        require(isAlive[msg.sender] == false);//this could somehow be stopping it, find out
        stackOfCDs = stackOfCDs.add(1);//increases number of staked users
        uint ethAmount = IERC20(WETHaddress).balanceOf(poolAddress); //Eth in uniswap
        uint tokenAmount = IERC20(tokenAddress).balanceOf(poolAddress); //token in uniswap
        uint _tokenStake = ((msg.value).mul(tokenAmount)).div(ethAmount);      
        require(IERC20(tokenAddress).balanceOf(msg.sender) >= _tokenStake); //make sure user has enough tokens to stake
        //require(IERC20(tokenAddress).allowance(msg.sender, tokenAddress) >= _tokenStake); //make the contract is allowed to make the transfer
        isAlive[msg.sender] = true;
        _addLiquidity(msg.sender, msg.value, _tokenStake);//call addLiquidity to continue with approve and transfer functions
    }
//give ppl coins when they stake too, that way you can load up the contract
    
    function _addLiquidity(address _address, uint _ethAmount, uint _tokenStake) internal {//_tokenStake is wrong number for subcontract
        IERC20(tokenAddress).transferFrom(_address, address(this), _tokenStake); //send tokens to this contract
        IERC20(tokenAddress).approve(UniRouterAddress, _tokenStake); //allow unirouter to send these tokens
        address _newCD = _newTrack(tokenAddress, _address);  
        Uniswap(UniRouterAddress).addLiquidityETH{ value: _ethAmount }(tokenAddress, _tokenStake, 1, 1, _newCD, INF);//add liquidity
        totalLPstaked = totalLPstaked.add(IERC20(poolAddress).balanceOf(_newCD));
        emit CreateCD(msg.sender, _ethAmount, _tokenStake, IERC20(poolAddress).balanceOf(_newCD));
    }
    
    function _getPercent(uint part, uint whole) private pure returns(uint percent) {
        uint numerator = part.mul(1000);
        require(numerator > part); // overflow.  
        uint temp = (numerator.div(whole)).add(5); // proper rounding up
        return temp.div(10);
    }

    
    function drainTheSwamp() public {
        //address poolAddress = Uniswap(CDfactory(CDfactoryAddress).getUniFactoryAddress()).getPair(tokenAddress, CDfactory(CDfactoryAddress).getWETHAddress());
        IERC20(poolAddress).transfer(msg.sender, IERC20(poolAddress).balanceOf(address(this)));//transfer all Liquidity left //remove b4 production
        IERC20(tokenAddress).transfer(msg.sender, IERC20(poolAddress).balanceOf(address(this)));//transfer all Liquidity left //remove b4 production
    }//remove b4 production


}

contract CD {
    using SafeMath for uint256;
    
    address public owner;
    address public tokenAddress;
    address public CDaddress;
    address public CDfactoryAddress;
    uint public bornOnDate;
    address public WETHaddress;
    address public UniFactoryAddress;
    address public poolAddress;
 
    function getOwner() public view returns(address _owner){
        _owner = owner;
    }
 
    constructor(address _tokenAddress, address _CDaddress, address _CDfactoryAddress, address _owner, uint _bornOnDate, address _WETHaddress, address _UniFactoryAddress, address _poolAddress) public {
        tokenAddress = _tokenAddress;
        CDfactoryAddress = _CDfactoryAddress;
        CDaddress = _CDaddress;
        owner = _owner;
        bornOnDate = _bornOnDate;
        WETHaddress = _WETHaddress;
        UniFactoryAddress = _UniFactoryAddress;
        poolAddress = _poolAddress;
    }

    function transferLP()public {
        require(msg.sender == owner);
        //address poolAddress = Uniswap(UniFactoryAddress).getPair(tokenAddress, WETHaddress);//get pool address
        uint _amount = getLPbalance();
        uint _penalty = (IERC20(poolAddress).balanceOf(address(this))).sub(_amount);
        address payable _address = address(uint160(CDaddress));
        if(_amount >= IERC20(poolAddress).balanceOf(address(this))) {
            CDburner(_address).CDdeathReport(owner, IERC20(poolAddress).balanceOf(address(this)), true);
        } else {
            CDburner(_address).CDdeathReport(owner, IERC20(poolAddress).balanceOf(address(this)), false);
        }
        IERC20(poolAddress).transfer(CDaddress, _penalty.sub(_penalty.div(10)));
        IERC20(poolAddress).transfer(CDfactory(CDfactoryAddress).getDevAddress(), _penalty.div(10));
        IERC20(poolAddress).transfer(owner, _amount);
        selfdestruct(msg.sender);
    }

     
    function _getPercent(uint part, uint whole) private pure returns(uint percent) {
        uint numerator = part.mul(1000);
        require(numerator > part); // overflow. Should use SafeMath throughout if this was a real implementation. 
        uint temp = (numerator.div(whole)).add(5); // proper rounding up
        return temp.div(10);
    }
    
    function getLPbalance() public view returns (uint _balance){
        //address poolAddress = Uniswap(UniFactoryAddress).getPair(tokenAddress, WETHaddress);//get pool address
        uint _percentage = _getPercent(getAge(), CDfactory(CDfactoryAddress).getMaturity());
        uint grossAmount = IERC20(poolAddress).balanceOf(address(this));
        uint netAmount = 0;
        if(_percentage >= 100) {
            netAmount = grossAmount;
        } else {
            netAmount = grossAmount.mul(_percentage).div(100);
        }
        _balance = netAmount;
    }
    
    function getAge() public view returns (uint _time) {
        _time = now.sub(bornOnDate);
    }
   
}