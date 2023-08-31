/*
 * get_XY_coo.c
 *
 *  Created on: July 14, 2023
 *      Author: chaedoyun
 */


#include "main.h"
#include <math.h>
#include <stdio.h>
#include "shared_defines.h"

#define FB       (499.2e6f)                    /* Basis frequency */
#define L_M_5    (SPEED_OF_LIGHT /FB /13.0f)   /* Lambda, m, CH5 */
#define D_M_5    (0.022777110597040736f)       /* Distance between centers of antennas, ~(L_M/2), m, CH5 */


//extern struct data data_rx;


int get_XY_cood(float pdoa, float dist, uint8_t *X_data, uint8_t *Y_data){
//unsigned char get_XY_cood(data * data_rx){

    float	r_m, x_m, y_m, l_m, d_m;
    double	p_diff_m; /* Path difference between the ports (m). */


	l_m = L_M_5;
	d_m = D_M_5;

    r_m = (dist-0.2) / 100.0f;

	p_diff_m = (pdoa / 360.0f * l_m);

    /* x and y from path difference and range */
    x_m = p_diff_m  / d_m * r_m;

    if (fabs(x_m) < r_m){
    	y_m = sqrt(r_m*r_m - x_m*x_m);
    }
    else{
    	y_m = 0.0f;
    }

    /* m -> cm */

    sprintf((char *)X_data, "%3.2f", (x_m * 100.0f));
    sprintf((char *)Y_data, "%3.2f", (y_m * 100.0f));

	return 0;
}
