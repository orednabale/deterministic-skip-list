pragma solidity ^0.5.1;

library DSkipList {

	uint256 constant private TAIL = 2;
	uint256 constant private BOTTOM = 3;
	uint256 constant private MAXKEY = 2**256 - 1;
	
	struct Node {
	  uint256 key;
	  uint256 r; // Right node
	  uint256 d; // Down node
	}

	struct SkipList {         // Skip list Struct
	    uint256 level;          // Skip list's highest level
	    uint256 nodeCount;        // Skip list's node Count
	    uint256 nextNodeId;	    
	    uint256 headId;
		mapping (uint256 => Node) list; // Mapping of key to its Node
		bool ascending;         // Skip list' order (ascending or descending)
	}

	function init(SkipList storage skip, bool ascending) public {
		skip.ascending = ascending;
        skip.level = 0;
        skip.nodeCount = 3;
        skip.nextNodeId = 4;
        skip.headId = 1;
        skip.list[skip.headId] = Node(MAXKEY,TAIL,BOTTOM);
		skip.list[TAIL] = Node(MAXKEY,TAIL,0);
		skip.list[BOTTOM] = Node(0, BOTTOM, BOTTOM);
	}

	function search(SkipList storage skip, uint256 v) view public returns (uint256 nodeId) {
		nodeId = skip.headId;

		while (v != skip.list[nodeId].key && nodeId != BOTTOM) {
			if (v < skip.list[nodeId].key)
				nodeId = skip.list[nodeId].d;
			else 
				nodeId = skip.list[nodeId].r;
		}
		return nodeId;
	}

	function insert(SkipList storage skip, uint256 v) internal returns (bool success) {
		uint256 t;
		uint256 x = skip.headId;
		success = true;
		skip.list[BOTTOM].key = v;

		while (x != BOTTOM) {
			while (v > skip.list[x].key)
				x = skip.list[x].r;

			if (skip.list[x].key > skip.list[skip.list[skip.list[skip.list[x].d].r].r].key) {
				t = skip.nextNodeId++;
				skip.nodeCount++;
				skip.list[t] = Node(0,0,0);
				skip.list[t].r = skip.list[x].r;
				skip.list[t].d = skip.list[skip.list[skip.list[x].d].r].r;
				skip.list[x].r = t;
				skip.list[t].key = skip.list[x].key;
				skip.list[x].key = skip.list[skip.list[skip.list[x].d].r].key;
			} else if (skip.list[x].d == BOTTOM)
				success = false;
			x = skip.list[x].d;
		}
		if (skip.list[skip.headId].r != TAIL) {
			t = skip.nextNodeId++;
			skip.nodeCount++;
			skip.list[t] = Node(MAXKEY,TAIL,skip.headId);
			skip.headId = t;
		}
		return(success);
	}


	function remove(SkipList storage skip, uint256 v) internal returns (bool success) {
		uint256 t;
		uint256 px;
		uint256 nx;
		uint256 x = skip.list[skip.headId].d;
		uint256 pred;
		uint256 lastAbove;

		success = (x != BOTTOM);
		skip.list[BOTTOM].key = v;
		lastAbove = skip.list[skip.headId].key;

		while (x != BOTTOM) {
			while (v > skip.list[x].key) {
				px = x;
				x = skip.list[x].r;
			}
			nx = skip.list[x].d;
			if (skip.list[x].key == skip.list[skip.list[nx].r].key)
				if (skip.list[x].key != lastAbove) {
					t = skip.list[x].r;
					if ((skip.list[t].key == skip.list[skip.list[skip.list[t].d].r].key) || (nx == BOTTOM)) {
						skip.list[x].r = skip.list[t].r;
						skip.list[x].key = skip.list[t].key;
						delete skip.list[t];
					} else {
						skip.list[x].key = skip.list[skip.list[t].d].key; 
						skip.list[t].d = skip.list[skip.list[t].d].r;
					}
				}
				else 
					if (skip.list[px].key <= skip.list[skip.list[skip.list[px].d].r].key) {
			          if (nx == BOTTOM) /* if del_Key is in elm of height>1 */
			            pred = skip.list[px].key; /* predecessor of del_key at bottom level*/
			          skip.list[px].r = skip.list[x].r; /* lower separator of previous+current gap */
			          skip.list[px].key = skip.list[x].key;
			          delete skip.list[x];
			          x = px;						
					}
			        else {
			      /* if >=2 elms in previous gap */
			      /* t = last elm in previous gap */			 
			      		if (skip.list[px].key == skip.list[skip.list[skip.list[skip.list[px].d].r].r].key) 
			      			t = skip.list[skip.list[px].d].r;
			      		else
			      			t = skip.list[skip.list[skip.list[px].d].r].r;
						skip.list[px].key = skip.list[t].key; /* raise last elm in previous gap & lower... */
						skip.list[x].d = skip.list[t].r; /* ... separator of previous+current gap */
			        } 
		    else if (nx == BOTTOM) /* if del_Key not in DSL */ 
		      success = false;
		    lastAbove = skip.list[x].key;
		    x = nx;
		}
		x = skip.list[skip.headId].d; /* Do a 2nd pass; del_key might have been in elm of height>1 */
		while (x != BOTTOM) {
			while (v > skip.list[x].key) 
				x = skip.list[x].r;
			if (v == skip.list[x].key) 
				skip.list[x].key = pred;
			x = skip.list[x].d;
		}
		if (skip.list[skip.list[skip.headId].d].r == TAIL) {
		/* lower header of DSL, if necessary */
			x = skip.headId;
			skip.headId = skip.list[x].d;
			delete skip.list[x];
		}
		return (success);
	}
}
