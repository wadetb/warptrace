#define TRACE_CS 	0
#define TRACE_VS 	1
#define TRACE_TCS 	2
#define TRACE_TES 	3
#define TRACE_GS 	4
#define TRACE_FS 	5

layout( std430, binding = 7 ) buffer TraceData {
    int tracePos;
    int pad[3];
    uvec4 traceData[1];
};

uint warpStartClock;

void BeginTrace(int id, int stage)
{
#if TRACE 
	warpStartClock = clock2x32ARB().y;
#endif	
}

void EndTrace(int id, int stage)
{
#if TRACE 
	uint activeMask = activeThreadsNV();
	if ( (activeMask & gl_ThreadLtMaskNV) == 0 )
	{
		uint header = (bitCount( activeMask ) - 1)
		            | (stage << 5)
		            | (gl_SMIDNV << 8)
		            | (gl_WarpIDNV << 16);

		uint warpEndClock = clock2x32ARB().y;

		int warpPos = atomicAdd( tracePos, 1 );
		traceData[warpPos] = uvec4( header, id, warpStartClock, warpEndClock ); 
	}
#endif	
}
