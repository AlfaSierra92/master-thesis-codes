#include "config.h"
#define IPERF_VERSION VERSION
#define IPERF_VERSION "2.2.0 AC"
#define IPERF_VERSION_DATE "10 April 2024"
#define IPERF_VERSION_MAJORHEX 0x00020002
#define IPERF_VERSION_MINORHEX 0x00000003
#define IPERF_BRANCH ""

/*
 * 	case 0:
 *	    sprintf(report->peerversion + strlen(report->peerversion) - 1,"-dev)");
 *	    break;
 *	case 1:
 *	    sprintf(report->peerversion + strlen(report->peerversion) - 1,"-rc)");
 *	    break;
 *	case 2:
 *	    sprintf(report->peerversion + strlen(report->peerversion) - 1,"-rc2)");
 *	    break;
 *	case 3:
 *	    break;
 *	case 4:
 *	    sprintf(report->peerversion + strlen(report->peerversion) - 1,"-private)");
 *	    break;
 *	case 5:
 *	    sprintf(report->peerversion + strlen(report->peerversion) - 1,"-master)");
 * 	    break;
 *	default:
 *	    sprintf(report->peerversion + strlen(report->peerversion) - 1, "-unk)");
 */