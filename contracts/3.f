{- 
  TASK 3 - Find and replace binary substring
  Binary string is represented as a cell linked list: string splitted to chunks,
  first chunk stored to the root cell, next one to the cell in ref and so on;
  each cell can have only one ref. 
  Write the method that find and replaces one flags in the binary string
  with another value. Flags and values can be can be of any length, but
  strictly up to 128 bits. The method must replace every flag it finds.
  Flag and the value to be replaced is guaranteed to be greater than 0.
  Lets give a simple example. We have the target flag 101110101 and the value
  to be written 111111111 as inputs, and a linked list of cells, in which the bit
  value of the first cell ends with ...10100001011, and in the ref we have cell that
  starts with 10101000111111...
  The output should be a linked list where the first
  cell ends with ...10100001111, and the second cell starts with 11111000111111...

-}

(int) log2(int x) asm "UBITSIZE DEC";
forall X -> int is_null (X x) asm "ISNULL";
forall X -> (tuple, (X)) tpop(tuple t) asm "UNCONS";

() recv_internal() {
}

(cell, int) solve(int flag, int value, cell ll, int prev, int prevs, int flags, int vals, int flc, int plc) {
  builder node = begin_cell();
  slice s = ll.begin_parse();

  int x = 0;
  int b = -1;

  while (~ s.slice_empty?()) {
    int one = s~load_uint(1);
    prev <<= 1;

    if (prevs != flags) {
      node~store_uint(prev & flc > 0, 1);
      prev -= (prev & flc > 0) * flc;
    } else {
      prev += 1;
    }

    if (prev == flag) {
      prev = value;
      int k = 0;
      
      while (k < vals) {
        prev <<= 1;
        node~store_uint(prev & plc > 0, 1);
        prev -= (prev & plc > 0) * plc;
      }

      prevs = 0;
      prev = 0;
    }

    x += 1;
  }

  if (s.slice_refs() > 0) {
    node = node.store_ref(solve(flag, value, s~load_ref(), prev, prevs, flags, vals, flc, plc));
  } else {
    int l = 0;
    plc = 1 << prevs;

    while (l < prevs) {
      prev <<= 1;
      node~store_uint(prev & plc > 0, 1);
      prev -= (prev & plc > 0) * plc;
    }
  }

  return node.end_cell();
}

;; testable
(cell) find_and_replace(int flag, int value, cell linked_list) method_id {
	builder node = begin_cell();

	int flags = log2(flag) + 1;
	int vals = log2(value) + 1;

	int flc = 1 << flags;
	int plc = 1 << vals;

	slice s = linked_list.begin_parse();
	while (~ s.slice_empty?()) {
		int one = s~load_uint(1);
		prev <<= 1;
		prev += one;

		if (prevs == flags) {
			node~store_uint(prev & flc > 0, 1);
			prev -= (prev & flc > 0) * flc;

			if (prev == flag) {
				prev = value;
				repeat(vals) {
					prev <<= 1;
					node~store_uint(prev & plc > 0, 1);
					prev -= (prev & plc > 0) * plc;
				}

				prev = 0;
				prevs = 0;
			}
		} else {
			prevs += 1;
		}
	}

	return node.end_cell();
}
