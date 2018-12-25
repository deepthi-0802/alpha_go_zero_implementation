__global__ void max_prob_to_coord_valid_mvs_kernel(float * prob_map, int * to_coord, 
		char * board, char * valid_mv_map_internal){
	int gm = blockIdx.x;
	int gm_offset = gm*MAP_SZ;
	float * prob_map_cur = &prob_map[gm*(MAP_SZ+1)];

	COUNT_VALID

	// determine max prob
	float max_prob = -999;
	int max_map_loc = MAP_SZ+1;
	DASSERT(n_valid_mvs > 0);

	for(int mv_ind = 0; mv_ind < n_valid_mvs; mv_ind++){ // skip pass move
		int map_loc = valid_mv_inds[mv_ind];
		CHK_VALID_MV_MAP_COORD(map_loc)
		DASSERT(map_loc == MAP_SZ || board[gm*MAP_SZ + map_loc] == 0)
		if(prob_map_cur[map_loc] <= max_prob)
			continue;
		max_map_loc = map_loc;
		max_prob = prob_map_cur[map_loc];
	}

	to_coord[gm] = max_map_loc;
	//printf("to_coord[%i] %i n_valid_mvs %i max_map_loc %i max_prob %f\n", gm, to_coord[gm],
	//	n_valid_mvs, max_map_loc, max_prob);
}

void max_prob_to_coord_valid_mvs_launcher(float * prob_map, int * to_coord){
	cudaError_t err;
	REQ_INIT

	max_prob_to_coord_valid_mvs_kernel <<< BATCH_SZ, 1 >>> (prob_map, to_coord, board, 
		valid_mv_map_internal); CHECK_CUDA_ERR

	VERIFY_BUFFER_INTEGRITY
}


