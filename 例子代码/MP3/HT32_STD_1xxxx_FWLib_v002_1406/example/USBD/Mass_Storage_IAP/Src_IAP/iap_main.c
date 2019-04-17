/*********************************************************************************************************//**
 * @file    USBD/Mass_Storage_IAP/Src_IAP/iap_main.c
 * @version $Rev:: 1218         $
 * @date    $Date:: 2018-04-16 #$
 * @brief   The main program of USB Device Mass Storage IAP example.
 *************************************************************************************************************
 * @attention
 *
 * Firmware Disclaimer Information
 *
 * 1. The customer hereby acknowledges and agrees that the program technical documentation, including the
 *    code, which is supplied by Holtek Semiconductor Inc., (hereinafter referred to as "HOLTEK") is the
 *    proprietary and confidential intellectual property of HOLTEK, and is protected by copyright law and
 *    other intellectual property laws.
 *
 * 2. The customer hereby acknowledges and agrees that the program technical documentation, including the
 *    code, is confidential information belonging to HOLTEK, and must not be disclosed to any third parties
 *    other than HOLTEK and the customer.
 *
 * 3. The program technical documentation, including the code, is provided "as is" and for customer reference
 *    only. After delivery by HOLTEK, the customer shall use the program technical documentation, including
 *    the code, at their own risk. HOLTEK disclaims any expressed, implied or statutory warranties, including
 *    the warranties of merchantability, satisfactory quality and fitness for a particular purpose.
 *
 * <h2><center>Copyright (C) Holtek Semiconductor Inc. All rights reserved</center></h2>
 ************************************************************************************************************/
// <<< Use Configuration Wizard in Context Menu >>>

/* Includes ------------------------------------------------------------------------------------------------*/
#include "ht32.h"
#include "ht32_board.h"
#include "ht32_board_config.h"
#include "ht32_usbd_core.h"
#include "iap_ht32_usbd_class.h"
#include "iap_ht32_usbd_descriptor.h"
#include "iap_handler.h"

/** @addtogroup HT32_Series_Peripheral_Examples HT32 Peripheral Examples
  * @{
  */

/** @addtogroup USBD_Examples USBD
  * @{
  */

/** @addtogroup USBD_Mass_Storage_IAP USBD Mass Storage IAP
  * @{
  */

/** @addtogroup Mass_Storage_IAP IAP
  * @{
  */


/* Global variables ----------------------------------------------------------------------------------------*/
__ALIGN4 USBDCore_TypeDef gUSBCore;
USBD_Driver_TypeDef gUSBDriver;
u32 gIsLowPowerAllowed = TRUE;

/* Private function prototypes -----------------------------------------------------------------------------*/
void CKCU_Configuration(void);
void USB_Configuration(void);
void USBPLL_Configuration(void);
void Suspend(u32 uPara);

/* Global functions ----------------------------------------------------------------------------------------*/
/*********************************************************************************************************//**
  * @brief  Main program.
  * @retval None
  ***********************************************************************************************************/
int main(void)
{
  CKCU_Configuration();               /* System Related configuration                                       */

  /*--------------------------------------------------------------------------------------------------------*/
  /* Use BOOT0 to decide start user application or IAP mode.                                                */
  /* Modify it if you want to use another GPIO pin.                                                         */
  /*--------------------------------------------------------------------------------------------------------*/
  #if 1
  if ((HT_FLASH->VMCR & 0x1) == 0x1)     /* The value of BOOT0 will be sampled to the VMCR                  */
                                         /* register of FMC after reset.                                    */
  #else
  /*--------------------------------------------------------------------------------------------------------*/
  /* Example that using Key1 to decide start user application or IAP mode.                                  */
  /* Key1 = Release: User application, Key1 = Pressed: IAP mode,                                            */
  /*--------------------------------------------------------------------------------------------------------*/
  GPIO_DirectionConfig(KEY1_BUTTON_GPIO_PORT, KEY1_BUTTON_GPIO_PIN, GPIO_DIR_IN);
  GPIO_InputConfig(KEY1_BUTTON_GPIO_PORT, KEY1_BUTTON_GPIO_PIN, ENABLE);
  if (GPIO_ReadInBit(KEY1_BUTTON_GPIO_PORT , KEY1_BUTTON_GPIO_PIN))
  #endif
  {
    /*------------------------------------------------------------------------------------------------------*/
    /* Check the register of FMC to decide start user application or IAP mode. User's application can       */
    /* set SBVT1 as BOOT_MODE_IAP and trigger a reset to start IAP mode. SBVT registers only reset by       */
    /* Power-on-reset.                                                                                      */
    /*------------------------------------------------------------------------------------------------------*/
    if (HT_FLASH->SBVT[1] != BOOT_MODE_IAP)
    {
      /*----------------------------------------------------------------------------------------------------*/
      /* Start user application when                                                                        */
      /*   1. GPIO = 1 and                                                                                  */
      /*   2. SBVT != BOOT_MODE_IAP and                                                                     */
      /*   3. SP and PC of user's application is in range                                                   */
      /*----------------------------------------------------------------------------------------------------*/
      IAP_Go(IAP_FLASH_START);        /* Never returned except SP or PC is not in range                     */
    }
  }

  /*--------------------------------------------------------------------------------------------------------*/
  /* Start IAP mode                                                                                         */
  /*   1. GPIO = 0 or                                                                                       */
  /*   2. SBVT == BOOT_MODE_IAP                                                                             */
  /*--------------------------------------------------------------------------------------------------------*/

  USB_Configuration();                /* USB Related configuration                                          */

  HT32F_DVB_USBConnect();

  while (1)
  {
    USBDCore_MainRoutine(&gUSBCore);
    IAP_Handler();
  }
}

/*********************************************************************************************************//**
  * @brief  Check AP is valid or not.
  * @retval FALSE or TRUE
  ***********************************************************************************************************/
u32 IAP_isAPValid(void)
{
  u32 SP, PC;
  u32 uResult = TRUE;

  /* Check Stack Point in range                                                                             */
  SP = rw(IAP_FLASH_START);
  if (SP < IAP_SRAM_START || SP > IAP_SRAM_END)
  {
    uResult = FALSE;
  }

  /* Check PC in range                                                                                      */
  PC = rw(IAP_FLASH_START + 0x4);
  if (PC < IAP_FLASH_START || PC > IAP_FLASH_END)
  {
    uResult = FALSE;
  }

  return uResult;
}

/*********************************************************************************************************//**
  * @brief  Configure the system clocks.
  * @retval None
  ***********************************************************************************************************/
void CKCU_Configuration(void)
{
#if 1
  CKCU_PeripClockConfig_TypeDef CKCUClock = {{ 0 }};
  CKCUClock.Bit.USBD       = 1;
  CKCUClock.Bit.AFIO       = 1;
  CKCUClock.Bit.EXTI       = 1;
  CKCU_PeripClockConfig(CKCUClock, ENABLE);
#endif

  /*--------------------------------------------------------------------------------------------------------*/
  /* Set USB Clock as PLL / 3                                                                               */
  /*--------------------------------------------------------------------------------------------------------*/
  CKCU_SetUSBPrescaler(HTCFG_USBPRE_DIV);

}

/*********************************************************************************************************//**
  * @brief  Configure USB.
  * @retval None
  ***********************************************************************************************************/
void USB_Configuration(void)
{
  #if (LIBCFG_CKCU_USB_PLL)
  USBPLL_Configuration();
  #endif

  gUSBCore.pDriver = (u32 *)&gUSBDriver;                /* Initiate memory pointer of USB driver            */
  gUSBCore.Power.CallBack_Suspend.func  = Suspend;      /* Install suspend call back function into USB core */
  //gUSBCore.Power.CallBack_Suspend.uPara = (u32)NULL;

  USBDDesc_Init(&gUSBCore.Device.Desc);                 /* Initiate memory pointer of descriptor            */
  USBDClass_Init(&gUSBCore.Class);                      /* Initiate USB Class layer                         */
  USBDCore_Init(&gUSBCore);                             /* Initiate USB Core layer                          */

#if (LIBCFG_CKCU_HSI_NO_AUTOTRIM)
#else
  // Need turn on if the USB clock source is from HSI (PLL clock Source)
  #if 0
  CKCU_HSIAutoTrimClkConfig(CKCU_ATC_USB);
  CKCU_HSIAutoTrimCmd(ENABLE);
  #endif
#endif

  NVIC_EnableIRQ(USB_IRQn);                             /* Enable USB device interrupt                      */
}

#if (LIBCFG_CKCU_USB_PLL)
/*********************************************************************************************************//**
 * @brief  Configure USB PLL
 * @retval None
 ************************************************************************************************************/
void USBPLL_Configuration(void)
{
  CKCU_PLLInitTypeDef PLLInit;

  PLLInit.ClockSource = CKCU_PLLSRC_HSE;
  //PLLInit.ClockSource = CKCU_PLLSRC_HSI;
  PLLInit.CFG = CKCU_USBPLL_8M_48M;
  PLLInit.BYPASSCmd = DISABLE;
  CKCU_USBPLLInit(&PLLInit);
  CKCU_USBPLLCmd(ENABLE);
  while (CKCU_GetClockReadyStatus(CKCU_FLAG_USBPLLRDY) == RESET);
  CKCU_USBClockConfig(CKCU_CKUSBPLL);
}
#endif

/*********************************************************************************************************//**
  * @brief  Suspend call back function which enter DeepSleep1
  * @param  uPara: Parameter for Call back function
  * @retval None
  ***********************************************************************************************************/
void Suspend(u32 uPara)
{
  #if (REMOTE_WAKEUP == 1)
  u32 IsRemoteWakeupAllowed;
  #endif
  if (gIsLowPowerAllowed)
  {

    #if (REMOTE_WAKEUP == 1)
    /* Disable EXTI interrupt to prevent interrupt occurred after wakeup                                    */
    EXTI_IntConfig(KEY1_BUTTON_EXTI_CHANNEL, DISABLE);
    IsRemoteWakeupAllowed = USBDCore_GetRemoteWakeUpFeature(&gUSBCore);

    if (IsRemoteWakeupAllowed == TRUE)
    {
      /* Enable EXTI wake event and clear wakeup flag                                                       */
      EXTI_WakeupEventConfig(KEY1_BUTTON_EXTI_CHANNEL, EXTI_WAKEUP_LOW_LEVEL, ENABLE);
      EXTI_ClearWakeupFlag(KEY1_BUTTON_EXTI_CHANNEL);
    }
    #endif

    __DBG_USBPrintf("%06ld >DEEPSLEEP\r\n", ++__DBG_USBCount);

    // Add your procedure here which disable related IO to reduce power consumption
    // ..................
    //

    /* For Bus powered device, you must enter DeepSleep1 when device has been suspended. For self-powered   */
    /* device, you may decide to enter DeepSleep1 or not depended on your application.                      */

    /* For the convenient during debugging and evaluation stage, the USBDCore_LowPower() is map to a null   */
    /* function by default. In the real product, you must map this function to the low power function of    */
    /* firmware library by setting USBDCORE_ENABLE_LOW_POWER as 1 (in the ht32fxxxx_usbdconf.h file).       */
    USBDCore_LowPower();

    // Add your procedure here which recovery related IO for application
    // ..................
    //

    __DBG_USBPrintf("%06ld <DEEPSLEEP\r\n", ++__DBG_USBCount);

    #if (REMOTE_WAKEUP == 1)
    if (EXTI_GetWakeupFlagStatus(KEY1_BUTTON_EXTI_CHANNEL) == SET)
    {
      __DBG_USBPrintf("%06ld WAKEUP\r\n", ++__DBG_USBCount);
      if (IsRemoteWakeupAllowed == TRUE && USBDCore_IsSuspend(&gUSBCore) == TRUE)
      {
        USBDCore_TriggerRemoteWakeup();
      }
    }

    if (IsRemoteWakeupAllowed == TRUE)
    {
      /* Disable EXTI wake event and clear wakeup flag                                                      */
      EXTI_WakeupEventConfig(KEY1_BUTTON_EXTI_CHANNEL, EXTI_WAKEUP_LOW_LEVEL, DISABLE);
      EXTI_ClearWakeupFlag(KEY1_BUTTON_EXTI_CHANNEL);
    }

    /* Clear EXTI edge flag and enable EXTI interrupt                                                       */
    EXTI_ClearEdgeFlag(KEY1_BUTTON_EXTI_CHANNEL);
    EXTI_IntConfig(KEY1_BUTTON_EXTI_CHANNEL, ENABLE);
    #endif
  }

  return;
}

#if (HT32_LIB_DEBUG == 1)
/*********************************************************************************************************//**
  * @brief  Report both the error name of the source file and the source line number.
  * @param  filename: pointer to the source file name.
  * @param  uline: error line source number.
  * @retval None
  ***********************************************************************************************************/
void assert_error(u8* filename, u32 uline)
{
  /*
     This function is called by IP library that the invalid parameters has been passed to the library API.
     Debug message can be added here.
     Example: printf("Parameter Error: file %s on line %d\r\n", filename, uline);
  */

  while (1)
  {
  }
}
#endif


/**
  * @}
  */

/**
  * @}
  */

/**
  * @}
  */

/**
  * @}
  */
