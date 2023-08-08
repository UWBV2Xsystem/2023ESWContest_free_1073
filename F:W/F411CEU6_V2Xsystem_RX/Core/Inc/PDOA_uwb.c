/*
 * PDOA_uwb.c
 *
 *  Created on: Jun 27, 2023
 *      Author: chaedoyun
 */


#include "main.h"
#include <math.h>
#include "deca_probe_interface.h"
#include <deca_device_api.h>
#include <deca_spi.h>
#include <example_selection.h>
#include <port.h>
#include <shared_defines.h>
#include <shared_functions.h>
#include <stdio.h>


struct data{
	uint8_t C_dist[6];
	float C_dist_f;
	uint8_t C_pdoa[6];
	float C_pdoa_f;
	uint8_t C_data[1];

	uint8_t C_x[6];
	uint8_t C_y[6];

	uint8_t T_dist[6];
	uint8_t T_pdoa[6];
	uint8_t T_data[2];
	uint8_t T_time[2];
};


struct data data_rx;
extern struct data data_rx;


extern void test_run_info(unsigned char *data);
static void rx_ok_cb(const dwt_cb_data_t *cb_data);
static void rx_err_cb(const dwt_cb_data_t *cb_data);




/* Example application name and version to display on LCD screen. */


/* Default communication configuration. We use default non-STS DW mode. see note 2*/
static dwt_config_t config_PDOA = {
    5,               /* Channel number. */
    DWT_PLEN_128,    /* Preamble length. Used in TX only. */
    DWT_PAC8,        /* Preamble acquisition chunk size. Used in RX only. */
    9,               /* TX preamble code. Used in TX only. */
    9,               /* RX preamble code. Used in RX only. */
    1,               /* 0 to use standard 8 symbol SFD, 1 to use non-standard 8 symbol, 2 for non-standard 16 symbol SFD and 3 for 4z 8 symbol SDF type */
    DWT_BR_6M8,      /* Data rate. */
    DWT_PHRMODE_STD, /* PHY header mode. */
    DWT_PHRRATE_STD, /* PHY header rate. */
    (129 + 8 - 8),   /* SFD timeout (preamble length + 1 + SFD length - PAC size). Used in RX only. */
    (DWT_STS_MODE_1 | DWT_STS_MODE_SDC), /* STS enabled */
    DWT_STS_LEN_256,                     /* Cipher length see allowed values in Enum dwt_sts_lengths_e */
    DWT_PDOA_M3                          /* PDOA mode 3 */
};

static const float pdoa_interval_shift = -22.0f;
float pdoa_deg = 0.0;

static uint8_t rx_buffer2[FRAME_LEN_MAX];
uint8_t rx_tmp[2] = "R";


int16_t pdoa_val = -1;
int16_t last_pdoa_val = 0;

uint8_t pdoa_message_data[40]; // Will hold the data to send to the virtual COM
//static uint8_t rx_buffer[FRAME_LEN_MAX];
/**
 * Application entry point.
 */
int UWB_pdoa(void){

    uint32_t dev_id;
    uint16_t frame_len;

    unsigned char car_f = 0;
    unsigned char tli_f = 0;

    /* Sends application name to test_run_info function. */

    port_set_dw_ic_spi_fastrate();

    /* Reset DW IC */
    reset_DWIC(); /* Target specific drive of RSTn line into DW IC low for a period. */

    Sleep(2); // Time needed for DW3000 to start up (transition from INIT_RC to IDLE_RC

    /* Probe for the correct device driver. */
    dwt_probe((struct dwt_probe_s *)&dw3000_probe_interf);

    dev_id = dwt_readdevid();


    while (!dwt_checkidlerc()) /* Need to make sure DW IC is in IDLE_RC before proceeding */ { };

    if (dwt_initialise(DWT_DW_IDLE) == DWT_ERROR)
    {
        test_run_info((unsigned char *)"INIT FAILED");
        while (1) { };
    }

    /* Configure DW3000. */
    /* if the dwt_configure returns DWT_ERROR either the PLL or RX calibration has failed the host should reset the device */
    if (dwt_configure(&config_PDOA))
    {
        test_run_info((unsigned char *)"CONFIG FAILED     ");
        while (1) { };
    }

    /* Register RX call-back. */
    dwt_setcallbacks(NULL, *rx_ok_cb, *rx_err_cb, *rx_err_cb, NULL, NULL, NULL);

    /* Enable wanted interrupts (RX good frames and RX errors). */
    dwt_setinterrupt(DWT_INT_RXFCG_BIT_MASK | SYS_STATUS_ALL_RX_ERR, 0, DWT_ENABLE_INT);

    /*Clearing the SPI ready interrupt*/
    dwt_writesysstatuslo(DWT_INT_RCINIT_BIT_MASK | DWT_INT_SPIRDY_BIT_MASK);

    /* Install DW IC IRQ handler. */
    port_set_dwic_isr(dwt_isr);

    /* Activate reception immediately. See NOTE 1 below. */
    dwt_rxenable(DWT_START_RX_IMMEDIATE);

    dwt_setleds(DWT_LEDS_ENABLE | DWT_LEDS_INIT_BLINK);
    /*loop forever receiving frames*/

    while (!(tli_f && car_f)){

    	int goodSts = 0; /* Used for checking STS quality in received signal */
    	int16_t stsQual; /* This will contain STS quality index */

    	    // Checking STS quality and STS status. See note 4
    	if (((goodSts = dwt_readstsquality(&stsQual)) >= 0)){
    	        pdoa_val = dwt_readpdoa();
    	    }

    	memset(rx_buffer2, 0, sizeof(rx_buffer2)); //meg_rx
    	dwt_rxenable(DWT_START_RX_IMMEDIATE);
    	frame_len = dwt_getframelength();

    	if (frame_len <= FRAME_LEN_MAX){

    		dwt_readrxdata(rx_buffer2, frame_len - FCS_LEN, 0); /* No need to read the FCS/CRC. */
		}

		/* Clear good RX frame event in the DW IC status register. */
		dwt_writesysstatuslo(DWT_INT_RXFCG_BIT_MASK);



        if ((last_pdoa_val != pdoa_val)&&(pdoa_val != 0)){

    		last_pdoa_val = pdoa_val;

    		pdoa_deg  = ((float)last_pdoa_val / (1 << 11)) * 180 / M_PI;
    		pdoa_deg = fmod(pdoa_deg - pdoa_interval_shift + 540.0f, 360.0f) + pdoa_interval_shift - 180.0f;


            if (rx_buffer2[2] == 'T' && tli_f == 0){
            	sprintf((char *)&data_rx.T_pdoa, "%d", (int)pdoa_deg);
            	data_rx.T_data[0] = (unsigned char)rx_buffer2[9];
            	data_rx.T_time[0] = (unsigned char)rx_buffer2[8];
            	tli_f = 1;

//            	test_run_info((unsigned char *)&rx_buffer2 + 9);
            }
            else if (rx_buffer2[2] == 'D' &&car_f == 0){
            	data_rx.C_pdoa_f = pdoa_deg;
            	sprintf((char *)&data_rx.C_pdoa, "%d", (int)pdoa_deg);
            	car_f = 1;
            }
        }
    }
    return DWT_SUCCESS;
}

//
//    while (1){
//
//    	int goodSts = 0; /* Used for checking STS quality in received signal */
//    	int16_t stsQual; /* This will contain STS quality index */
//
//    	    // Checking STS quality and STS status. See note 4
//    	if (((goodSts = dwt_readstsquality(&stsQual)) >= 0)){
//    	        pdoa_val = dwt_readpdoa();
//    	    }
//
//    	memset(rx_buffer2, 0, sizeof(rx_buffer2)); //meg_rx
//    	dwt_rxenable(DWT_START_RX_IMMEDIATE);
//    	frame_len = dwt_getframelength();
//
//    	if (frame_len <= FRAME_LEN_MAX){
//
//    		dwt_readrxdata(rx_buffer2, frame_len - FCS_LEN, 0); /* No need to read the FCS/CRC. */
//		}
//
//		/* Clear good RX frame event in the DW IC status register. */
//		dwt_writesysstatuslo(DWT_INT_RXFCG_BIT_MASK);
//
//
//
//        if ((last_pdoa_val != pdoa_val)&&(pdoa_val != 0)){
//
//        	last_pdoa_val = pdoa_val;
//
//        	pdoa_deg  = ((float)last_pdoa_val / (1 << 11)) * 180 / M_PI;
//        	pdoa_deg = fmod(pdoa_deg - pdoa_interval_shift + 540.0f, 360.0f) + pdoa_interval_shift - 180.0f;
//
//            sprintf((char *)&pdoa_message_data, "PDOA: %d n\n", (int)pdoa_deg);
//            test_run_info((unsigned char *)&pdoa_message_data);
//
//
//
//
//            if (rx_buffer2[2] == 'T'){
//            	test_run_info((unsigned char *)"C : ");
//
//            	//rx_tmp[0] = rx_buffer2[9];
//				test_run_info((unsigned char *)&rx_buffer2 + 9);
//            }
//
//			test_run_info((unsigned char *)"\n");
//            return 0;
//        }
//    }
//    return DWT_SUCCESS;
//}

/*! ------------------------------------------------------------------------------------------------------------------
 * @fn rx_ok_cb()
 *
 * @brief Callback to process RX good frame events
 *
 * @param  cb_data  callback data
 *
 * @return  none
 */
static void rx_ok_cb(const dwt_cb_data_t *cb_data){


    int goodSts = 0; /* Used for checking STS quality in received signal */
    int16_t stsQual; /* This will contain STS quality index */

    (void)cb_data;
    // Checking STS quality and STS status. See note 4
    if (((goodSts = dwt_readstsquality(&stsQual)) >= 0))
    {
        pdoa_val = dwt_readpdoa();
    }

    dwt_rxenable(DWT_START_RX_IMMEDIATE);
}

/*! ------------------------------------------------------------------------------------------------------------------
 * @fn rx_err_cb()
 *
 * @brief Callback to process RX error and timeout events
 *
 * @param  cb_data  callback data
 *
 * @return  none
 */
static void rx_err_cb(const dwt_cb_data_t *cb_data)
{
    (void)cb_data;
    dwt_rxenable(DWT_START_RX_IMMEDIATE);
}


/*****************************************************************************************************************************************************
 * NOTES:
 *
 * 1. Manual reception activation is performed here but DW IC offers several features that can be used to handle more complex scenarios or to
 *    optimise system's overall performance (e.g. timeout after a given time, automatic re-enabling of reception in case of errors, etc.).
 * 2. This is the default configuration recommended for optimum performance. An offset between the clocks of the transmitter and receiver will
 *    occur. The DW3000 can tolerate a difference of +/- 20ppm. For optimum performance an offset of +/- 5ppm is recommended.
 * 3. A natural offset will always occur between any two boards. To combat this offset the transmitter and receiver should be placed
 *    with a real PDOA of 0 degrees. When the PDOA is calculated this will return a non-zero value. This value should be subtracted from all
 *    PDOA values obtained by the receiver in order to obtain a calibrated PDOA.
 * 4. If the STS quality is poor the returned PDoA value will not be accurate and as such will not be recorded
 ****************************************************************************************************************************************************/
