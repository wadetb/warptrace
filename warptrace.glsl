/*
    Warp trace - Warp-level performance analysis for GPUs 
    Copyright (C) 2016  Wade Brainerd
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/
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
