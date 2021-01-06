
pragma solidity ^0.5.1;

import "DSkipList.sol";

contract TestDSkipList {

    using DSkipList for DSkipList.SkipList;
    
    uint256 constant private TAIL = 2;
    uint256 constant private BOTTOM = 3;

    DSkipList.SkipList public skip;

    uint256 [][][] public skipNodes;
    uint256 [][] public levelNodes;
    
    event Log(string where, uint256 value);

    constructor () public {
        skip.init(true);
    }

    function insert(uint256 value) public {
        skip.insert(value);
        emit Log("insert", value);
    }
    function remove(uint256 value) public {
        skip.remove(value);
        emit Log("remove", value);
    }
    
    function fillSkipNodes() public {
        delete skipNodes;
        uint256 x = skip.headId;
        while (x != BOTTOM) {
            uint256 y;
            y = x;
            while (y != TAIL) {
                levelNodes.push([skip.list[y].key, skip.list[y].d, skip.list[y].r]);
                y = skip.list[y].r;
            }
            skipNodes.push(levelNodes);
            delete levelNodes;
            x = skip.list[x].d;
        }
    }
    
}
