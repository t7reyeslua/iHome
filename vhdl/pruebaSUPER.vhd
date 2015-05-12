----------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pruebaSUPER is
Port ( 	CLK 		: in  STD_LOGIC;
			iSistema	: in  STD_LOGIC;
			iLuces	: in  STD_LOGIC;
			iFaros	: in  STD_LOGIC;
			iPuerta	: in  STD_LOGIC;
			iPorton	: in  STD_LOGIC;
			iAlarma	: in  STD_LOGIC;
			iAlberca	: in  STD_LOGIC;
			iRobo		: in  STD_LOGIC;
			kb_clk	: in	STD_LOGIC;
			kb_data	: in	STD_LOGIC;
			ioRx		: in  STD_LOGIC;
			ioTx		: out  STD_LOGIC;
			salBCD	: out STD_LOGIC_VECTOR (7 downto 0);
			ENE		: out STD_LOGIC_VECTOR (3 downto 0);
			ledprueba: out std_logic;
			ledprueba2: out std_logic;
			ledprueba3: out std_logic;
			HS			: out std_logic;
			VS			: out std_logic;	 
         Green		: out STD_LOGIC_VECTOR (3 downto 0);
			Blue		: out STD_LOGIC_VECTOR (3 downto 0);
         Red		: out STD_LOGIC_VECTOR (3 downto 0));
end pruebaSUPER;


architecture Behavioral of pruebaSUPER is

--**********COMPONENTES**************************************************
component CLKs is
	Port (  Clk_in : in  STD_LOGIC;
           CLK_out: out STD_LOGIC);
end component;

component contador is
    Port ( inc : in std_logic;
           reset : in std_logic;
			  run: in std_logic;
           s : inout std_logic_vector(9 downto 0));
end component;


component testram is 
Port ( 
	address: in std_logic_vector( 6 downto 0 );
	data: 	out std_logic_vector( 3 downto 0 ));
end component;

component keyboard is
	port(	keyboard_clk	: IN	STD_LOGIC;
			keyboard_data	: IN	STD_LOGIC;
			clock_25Mhz	: IN	STD_LOGIC;
			reset		: IN	STD_LOGIC;
			read_kb	: IN	STD_LOGIC;
			scan_code	: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
			scan_ready	: OUT	STD_LOGIC);
end component;

component Display is
Port (
	-- Input
	Clk_in	: in  STD_LOGIC;		-- Clock
	-- Data
	D0 : in  STD_LOGIC_VECTOR (3 downto 0);
	D1: in  STD_LOGIC_VECTOR (3 downto 0);
	D2: in  STD_LOGIC_VECTOR (3 downto 0);
	D3: in  STD_LOGIC_VECTOR (3 downto 0);
		
	-- Output
	D7 : out  STD_LOGIC_VECTOR (7 downto 0);	-- Data
	En : out  STD_LOGIC_VECTOR (3 downto 0)	-- Enable
		);
end component;


component uart_tx is
    Port (   data_in 			: in std_logic_vector(7 downto 0);
             write_buffer 		: in std_logic;
             reset_buffer 		: in std_logic;
             en_16_x_baud 		: in std_logic;
             serial_out 		: out std_logic;
             buffer_full 		: out std_logic;
             buffer_half_full : out std_logic;
             clk 					: in std_logic);
end component;

component uart_rx is
    Port (   serial_in 			: in std_logic;
             data_out 			: out std_logic_vector(7 downto 0);
             read_buffer 		: in std_logic;
             reset_buffer 		: in std_logic;
             en_16_x_baud 		: in std_logic;
             buffer_data_present : out std_logic;
             buffer_full 		: out std_logic;
             buffer_half_full : out std_logic;
             clk 					: in std_logic);
end component;

--***********************************************************************

--************SEÑALES****************************************************

--Serial===================================================
signal baud_count: integer range 0 to 650:=0;
signal en_16_x_baud: std_logic;

signal datoTx			: std_logic_vector(7 downto 0);
signal wbufferTx 		: std_logic;
signal resetbufferTx : std_logic;
signal bufferFTx		: std_logic;
signal bufferHFTx		: std_logic;
signal transmitting	: std_logic;

signal datoRx			: std_logic_vector(7 downto 0);
signal rbufferRx		: std_logic;
signal resetbufferRx : std_logic;
signal bufferReadyRx  : std_logic;
signal bufferFRx		: std_logic;
signal bufferHFRx 	: std_logic;

signal sendAlgo,sendPuerta,sendPorton,sendAlberca,sendRobo,sendAlarma:std_logic;
signal incRx,incTx:std_logic;
signal paqueteRxcompleto, paqueteTxcompleto:std_logic;

signal dato55Tx		:std_logic_vector(7 downto 0):="01010101";
signal datoIdTx		:std_logic_vector(7 downto 0):="00000010";
signal datoC1Tx,datoC2Tx,datoC3Tx:std_logic_vector(7 downto 0);
signal datoC4Tx		:std_logic_vector(7 downto 0):="00000000";
signal datoAATx		:std_logic_vector(7 downto 0):="10101010";

signal dato55Rx		:std_logic_vector(7 downto 0);
signal datoIdRx		:std_logic_vector(7 downto 0);
signal datoC1Rx,datoC2Rx,datoC3Rx:std_logic_vector(7 downto 0);
signal datoC4Rx		:std_logic_vector(7 downto 0);
signal datoAARx		:std_logic_vector(7 downto 0);

signal contRx,contTx: std_logic_vector(3 downto 0);

--CLKs===================================================
signal clk25 : std_logic;
signal CLK1s : std_logic;
signal cont1seg: STD_LOGIC_VECTOR(25 downto 0);
signal CLKmedioS : std_logic;
signal contMedioSeg: STD_LOGIC_VECTOR(25 downto 0);
signal contMov3: STD_LOGIC_VECTOR(25 downto 0);
signal CLK1min: std_logic;
signal cont1min: STD_LOGIC_VECTOR(25 downto 0);
signal msDelay, sDelay: STD_LOGIC_VECTOR(25 downto 0);
signal clk_lento: std_logic_vector(20 downto 0);	--registro para dividir la frecuencia (para la velocidad de movimiento del dibujo)
signal clkMov,clkMov2,clkMov3: std_logic;
signal CLKcuadro : std_logic;
signal contCuadro: STD_LOGIC_VECTOR(25 downto 0);

--TECLADO================================================

signal kbcode 	: std_logic_vector(7 downto 0);
signal kbready	: std_logic;
signal resetKB	: std_logic;
signal readKB	: std_logic  :='1';

signal keyEXT: std_logic;
signal numeroKB: std_logic_vector(3 downto 0):="1010";

signal enterPUSHED, enterOFF:std_logic;

--Display================================================
signal disp1,disp2,disp3,disp4: std_logic_vector(3 downto 0):="1010";



--Señales de RAM--========================================

--**relojito
signal hrH: std_logic_vector( 3 downto 0 ); --decenas hora
signal hrH_address: std_logic_vector( 6 downto 0 );
signal hrL: std_logic_vector( 3 downto 0 ); --unidades hora
signal hrL_address: std_logic_vector( 6 downto 0 );
signal minH: std_logic_vector( 3 downto 0 ); --decenas min
signal minH_address: std_logic_vector( 6 downto 0 );
signal minL: std_logic_vector( 3 downto 0 ); --unidades min
signal minL_address: std_logic_vector( 6 downto 0 );
signal dosPuntos: std_logic_vector( 3 downto 0 ); 
signal dosPuntos_address: std_logic_vector( 6 downto 0 );
signal onHoraLB, onHrH, onHrL, onMinH, onMinL, on2p:std_logic;

signal contHrH: std_logic_vector(9 downto 0);
signal contHrL: std_logic_vector(9 downto 0);
signal contMinH: std_logic_vector(9 downto 0);
signal contMinL: std_logic_vector(9 downto 0);

signal resetMinL,resetMinH,resetHrL,resetHrH:std_logic;


--**interruptor ON/OFF

signal onO: std_logic_vector( 3 downto 0 ); 
signal onO_address: std_logic_vector( 6 downto 0 );
signal onN: std_logic_vector( 3 downto 0 ); 
signal onN_address: std_logic_vector( 6 downto 0 );
signal offO: std_logic_vector( 3 downto 0 );
signal offO_address: std_logic_vector( 6 downto 0 );
signal offF1: std_logic_vector( 3 downto 0 ); 
signal offF1_address: std_logic_vector( 6 downto 0 );
signal offF2: std_logic_vector( 3 downto 0 ); 
signal offF2_address: std_logic_vector( 6 downto 0 );
signal onON_o,onON_n,onOFF_o,onOFF_f1,onOFF_f2, onLetreroON, onLetreroOFF:std_logic;


--Señal de VGA====================================================
--//señal principal
signal Hcont,Vcont: std_logic_vector(9 downto 0);
signal resetH, resetV, HSaux,VSaux: std_logic;

--//señales de control de intensidades
signal intFaroFL,intFaroFR:std_logic_vector(1 downto 0):="00";
signal intFaroBL,intFaroBR:std_logic_vector(1 downto 0):="00";

signal intventanaULF,intventanaDLF:std_logic_vector(1 downto 0):="00";
signal intventanaURF,intventanaDRF:std_logic_vector(1 downto 0):="00";
signal intventanaURB,intventanaDRB:std_logic_vector(1 downto 0):="00";

signal banderaTodasLucesIgual:std_logic;
signal banderaTodosFarosIgual:std_logic;
signal banderaTodasLucesP1Igual:std_logic;
signal banderaTodosFarosFIgual:std_logic;
signal banderaTodasLucesP2Igual:std_logic;
signal banderaTodosFarosBIgual:std_logic;

--//colores recuadros
signal RGBAux: std_logic_vector(11 downto 0);
signal RGBc1: std_logic_vector(11 downto 0);
signal RGBc2: std_logic_vector(11 downto 0);
signal RGBc3: std_logic_vector(11 downto 0);
signal RGBlb: std_logic_vector(11 downto 0);

signal RGBhrH: std_logic_vector(11 downto 0);
signal RGBhrL: std_logic_vector(11 downto 0);
signal RGBminH: std_logic_vector(11 downto 0);
signal RGBminL: std_logic_vector(11 downto 0);
signal RGB2p: std_logic_vector(11 downto 0);

signal RGBletreroONverde: std_logic_vector(11 downto 0):="000011110000";
signal RGBonO, RGBonN:std_logic_vector(11 downto 0);
signal RGBletreroOFFrojo: std_logic_vector(11 downto 0):="111100000000";
signal RGBoffO, RGBoffF1, RGBoffF2:std_logic_vector(11 downto 0);

--RGB auxiliares de C1
signal RGBcalleC1: std_logic_vector(11 downto 0);
signal RGBbanquetaC1: std_logic_vector(11 downto 0);
signal RGBbordeBanquetaC1: std_logic_vector(11 downto 0);
signal RGBpastoFueraC1: std_logic_vector(11 downto 0);
signal RGBfaroFLc1: std_logic_vector(11 downto 0);
signal RGBfaroFRc1: std_logic_vector(11 downto 0);
signal RGBfaroBLc1: std_logic_vector(11 downto 0);
signal RGBfaroBRc1: std_logic_vector(11 downto 0);
signal RGBanyPoste: std_logic_vector(11 downto 0):="110011001100";
signal RGBporton:std_logic_vector(11 downto 0):="110000000000";
signal RGBparedPuertaFrenteC1:std_logic_vector(11 downto 0);
signal RGBmuroFC1:std_logic_vector(11 downto 0):="111100000000";
signal RGBmuroBC1:std_logic_vector(11 downto 0):="111100000000";
signal RGBmurosCurvosC1:std_logic_vector(11 downto 0);
signal RGBventanaULFc1:std_logic_vector(11 downto 0);
signal RGBventanaURFc1:std_logic_vector(11 downto 0);
signal RGBventanaDLFc1:std_logic_vector(11 downto 0);
signal RGBventanaDRFc1:std_logic_vector(11 downto 0);
signal RGBmurosLateralesC1:std_logic_vector(11 downto 0);
signal RGBmurosLateralesTechoC1:std_logic_vector(11 downto 0);
signal RGBtechitosC1:std_logic_vector(11 downto 0);
signal RGBbalconesC1:std_logic_vector(11 downto 0);
signal RGBazoteaC1:std_logic_vector(11 downto 0);
signal RGBpuertaCasaC1:std_logic_vector(11 downto 0);
signal RGBmarcoVentanasYpuertaC1:std_logic_vector(11 downto 0);
signal RGBfachadaCasa:std_logic_vector(11 downto 0):="111111110011";
signal RGBescalonesC1:std_logic_vector(11 downto 0);
signal RGBfachadaEscalonesC1:std_logic_vector(11 downto 0);
signal RGBpastoDentroC1:std_logic_vector(11 downto 0);
signal RGBcieloC1:std_logic_vector(11 downto 0);

--RGB auxiliares de C2
signal RGBcalleC2:std_logic_vector(11 downto 0);
signal RGBbanquetaC2:std_logic_vector(11 downto 0);
signal RGBmurosC2:std_logic_vector(11 downto 0);
signal RGBazoteaC2:std_logic_vector(11 downto 0);
signal RGBalbercaC2:std_logic_vector(11 downto 0):="000001110001";
signal RGBmarcoAlbercaC2:std_logic_vector(11 downto 0);
signal RGBpastoFueraC2:std_logic_vector(11 downto 0);
signal RGBpastoDentroC2:std_logic_vector(11 downto 0);
signal RGBfaroFLc2: std_logic_vector(11 downto 0);
signal RGBfaroFRc2: std_logic_vector(11 downto 0);
signal RGBfaroBLc2: std_logic_vector(11 downto 0);
signal RGBfaroBRc2: std_logic_vector(11 downto 0);
signal RGBolasON: std_logic_vector(11 downto 0);
signal RGBolasOFF: std_logic_vector(11 downto 0);
signal RGBolasONaux: std_logic_vector(11 downto 0);
signal RGBolasOFFaux: std_logic_vector(11 downto 0);

--RGB auxiliares de C3

signal RGBventanaDRBc3:std_logic_vector(11 downto 0);
signal RGBventanaDRFc3:std_logic_vector(11 downto 0);
signal RGBventanaURBc3:std_logic_vector(11 downto 0);
signal RGBventanaURFc3:std_logic_vector(11 downto 0);
signal RGBpastoFueraC3:std_logic_vector(11 downto 0);
signal RGBbanquetaC3:std_logic_vector(11 downto 0);
signal RGBmurosVc3:std_logic_vector(11 downto 0):="111100000000";
signal RGBfaroFRc3: std_logic_vector(11 downto 0);
signal RGBfaroBRc3: std_logic_vector(11 downto 0);
signal RGBescalonesC3: std_logic_vector(11 downto 0);
signal RGBmuroHc3: std_logic_vector(11 downto 0);
signal RGBcieloC3: std_logic_vector(11 downto 0);

--RGB auxiliares de LB
signal RGBinterruptor: std_logic_vector(11 downto 0);
signal RGBcelular,RGBcelularAUX: std_logic_vector(11 downto 0);
signal RGBcelTeclado:std_logic_vector(11 downto 0);
signal RGBcelPantalla:std_logic_vector(11 downto 0);
signal RGBlockCentro:std_logic_vector(11 downto 0);
signal RGBlockCandado:std_logic_vector(11 downto 0);
signal RGBlockArco:std_logic_vector(11 downto 0);


--//banderas sobre donde se está==========================================
signal onScreen: std_logic;
signal onLeftBar: std_logic;
signal onCap1, onCap2, onCap3: std_logic;
signal onAnyCap: std_logic;

signal onLeftBarFrame: std_logic;
signal onMiddleCapsHFrame: std_logic;
signal onMiddleCapsVFrame: std_logic;
signal onCapsFrame: std_logic; 

signal onFrameC1, onFrameC2, onFrameC3: std_logic;
--
----***banderas de leftBar:
signal interruptorLB:std_logic;
signal onFrameInterruptor:std_logic;

signal celAntenaLB:std_logic;
signal celPantallaLB:std_logic;
signal celTecladoLB:std_logic;
signal celCarcazaLB:std_logic;
signal onFrameCel:std_logic;

signal lockCentroLB:std_logic;
signal lockCandadoLB:std_logic;
signal lockRVarcoLB:std_logic;
signal lockHarcoLB:std_logic;
signal lockLV1arcoLB:std_logic;
signal lockLV2arcoLB:std_logic;
signal onFrameLock:std_logic;

----***banderas de c1:
signal cieloC1 :std_logic;
signal pastoFueraC1:std_logic;
signal banquetaC1, bordeBanquetaC1:std_logic;
signal calleC1:std_logic;
signal faroFRc1,faroBRc1,faroFLc1,faroBLc1,anyFaroC1:std_logic;
signal posteFRc1,posteBRc1,posteFLc1,posteBLc1,anyPosteC1:std_logic;
signal muroFc1, muroBc1, muroFcurvoC1:std_logic;
signal muroRcasaC1, muroRtechoCasaC1, muroLcasaC1,muroLtechoCasaC1:std_logic;
signal fachadaCasaC1:std_logic;
signal azoteaC1:std_logic;
signal techoUC1, techoDC1:std_logic;
signal balconUC1,balconDC1:std_logic;
signal paredPuertaFrenteC1,puertaFrenteC1,puertaCasaC1,portonC1,bordePuertaFrenteC1:std_logic;
signal ventanaURFc1,ventanaULFc1,ventanaDRFc1,ventanaDLFc1,marcoVentanasYpuertaC1,anyVentanaC1:std_logic;
signal escalon1C1,escalon2C1,escalon3C1,anyEscalonC1:std_logic;
signal fachadaCasaEscalonesC1: std_logic;
signal pastoDentroC1:std_logic;
signal anyElementoC1:std_logic;


----***banderas de c2:
signal calleC2,banquetaC2:std_logic;
signal puertaFrenteC2, portonC2:std_logic;
signal murosVc2, murosHc2:std_logic;
signal pastoFueraC2, pastoDentroC2:std_logic;
signal azoteaC2:std_logic;
signal caminitoC2:std_logic;
signal albercaC2, marcoAlbercaC2:std_logic;
signal faroFDc2, faroFIc2, faroBDc2, faroBIc2:std_logic;
signal ola1,ola2,ola3,ola4,ola5,ola6,anyOla:std_logic;

----***banderas de c3:
signal cieloC3, pastoFueraC3, banquetaC3:std_logic;
signal murosVc3, muroHc3, muroRcasaC3:std_logic;
signal faroFRc3, faroBRc3:std_logic;
signal posteFRc3, posteBRc3:std_logic;
signal ventanaURFc3, ventanaURBc3, ventanaDRFc3, ventanaDRBc3,anyVentanaC3:std_logic;
signal escalon1c3, escalon2c3, escalon3c3,anyEscalonC3:std_logic;



--// "constantes" de limites==========================================================
signal limCapsD: integer:=80;
signal limCapsMv:integer:=360;
signal limCapsMh:integer:=240;
--

----***limites de LeftBar***********************************************

--lim del interruptor============
signal limLinterruptorLB:integer:=30;
signal limRinterruptorLB:integer:=60;
signal limSUPinterruptorLB:integer:=65;
signal limINFinterruptorLB:integer:=73;

signal limSupLetreroONOFF: integer:=45;
signal limInfLetreroONOFF: integer:=53;

signal limLON_o: integer:=30 ;
signal limRON_o: integer:=34 ;
signal limLON_n: integer:=35 ;
signal limRON_n: integer:=39 ;

signal limLOFF_o: integer:=45 ;
signal limROFF_o: integer:=49 ;
signal limLOFF_f1: integer:=50 ;
signal limROFF_f1: integer:=54 ;
signal limLOFF_f2: integer:=55 ;
signal limROFF_f2: integer:=59 ;


--limdel celular==================

signal limRcelAntenaLB:integer:=37;
signal limSUPcelAntenaLB:integer:=240;

signal limSUPcelPantallaLB:integer:=258;
signal limINFcelPantallaLB:integer:=266;

signal limSUPcelTecladoLB:integer:=269;
signal limINFcelTecladoLB:integer:=285;

signal limSUPcelCarcazaLB:integer:=255;
signal limINFcelCarcazaLB:integer:=290;
signal limLcelCarcazaLB:integer:=35;
signal limRcelCarcazaLB:integer:=55;

--lims del CANDADO======
signal limLlockCandadoLB:integer:=30;
signal limRlockCandadoLB:integer:=60;
signal limSUPlockCandadoLB:integer:=390;
signal limINFlockCandadoLB:integer:=420;

signal limRlockRVarcoLB:integer:=33;
signal limSUPlockRVarcoLB:integer:=380;

signal limSUPlockHarcoLB:integer:=377;

signal limLlockLVarcoLB:integer:=57;
signal limINFlockLVarcoLB:integer:=385;

--lims de la HORA============
signal limSupHora: integer:=146;
signal limInfHora: integer:=154;

signal limLhrH: integer:=30 ;
signal limRhrH: integer:=34 ;
signal limLhrL: integer:=35 ;
signal limRhrL: integer:=39 ;

signal limLdosPuntos: integer:=40 ;
signal limRdosPuntos: integer:=44 ;

signal limLminH: integer:=45 ;
signal limRminH: integer:=49 ;
signal limLminL: integer:=50 ;
signal limRminL: integer:=54 ;


----***limites de c1****************************************************
signal limHorizonteC1   :integer:=150;
signal limSupBanquetaC1 :integer:=210;
signal limInfBanquetaC1 :integer:=225;
signal limLentreBanquetasC1  :integer:=305;
signal limRentreBanquetasC1  :integer:=415;

signal limLMuroFrente1C1 :integer:=190;
signal limRMuroFrente1C1 :integer:=305;
signal limLMuroFrente2C1 :integer:=430;
signal limRMuroFrente2C1 :integer:=530;
signal limSupMuroFrenteC1:integer:=160;

signal limLMuroAtras1C1 :integer:=201;
signal limRMuroAtras1C1 :integer:=255;
signal limLMuroAtras2C1 :integer:=465;
signal limRMuroAtras2C1 :integer:=519;
signal limSupMuroAtrasC1:integer:=140;

signal limLPuertaFrenteC1 :integer:=285;--292
signal limRPuertaFrenteC1 :integer:=300;
signal limLPortonC1		  :integer:=305;
signal limRPortonC1		  :integer:=430;
signal xPuertaFrenteC1    :std_logic_vector(8 downto 0);
signal xPortonC1    		  :std_logic_vector(8 downto 0);

signal limLPuertaFrenteC1aux:std_logic_vector(8 downto 0);
signal limLPortonC1aux:std_logic_vector(8 downto 0);


signal limRPosteFLc1		:integer:=196;
signal limSupPostesFc1	:integer:=130;
signal limLPosteFRc1		:integer:=524;

signal limLPosteBLc1		:integer:=201;
signal limRPosteBLc1		:integer:=207;
signal limSupPostesBc1	:integer:=110;
signal limLPosteBRc1		:integer:=513;
signal limRPosteBRc1		:integer:=519;

signal limSupFarosFc1	:integer:=100;
signal limSupFarosBc1	:integer:=85;

signal limIntMuroLcasaC1	:integer:=260;
signal limIntMuroRcasaC1	:integer:=460;

signal limSupAzoteaC1	:integer:=45;
signal limInfAzoteaC1	:integer:=60;
signal limInfTechoUC1	:integer:=65;
signal limInfFachadaP2C1:integer:=105;
signal limSupTechoDC1	:integer:=120;
signal limInfTechoDC1	:integer:=125;
signal limInfFachadaP1C1:integer:=165;
signal limInfCasaC1		:integer:=195;

signal limSupEscalon1C1 :integer:=180;
signal limSupEscalon2C1 :integer:=185;
signal limSupEscalon3C1 :integer:=190;
signal limLEscalon1C1  :integer:=321;
signal limREscalon1C1  :integer:=399;
signal limLEscalon2C1  :integer:=318;
signal limREscalon2C1  :integer:=402;
signal limLEscalon3C1  :integer:=315;
signal limREscalon3C1  :integer:=405;

signal limInfVentanasP2C1 :integer:=90;
signal limLenMedioVentanasP2C1 :integer:=341;
signal limRenMedioVentanasP2C1 :integer:=379;

signal limSupVentanasP1C1  :integer:=128;
signal limInfVentanasP1C1  :integer:=145;
signal limLintVentanasP1C1 :integer:=336;
signal limRintVentanasP1C1 :integer:=386;

signal limLPuertaCasaC1:integer:=346;
signal limRPuertaCasaC1:integer:=374;
signal limSupPuertaCasaC1:integer:=131;

------***limites de c2********************************************
signal limSupBanquetaC2 :integer:=450;
signal limInfBanquetaC2 :integer:=465;
signal limLIntBanquetaC2   :integer:=185;
signal limRIntBanquetaC2   :integer:=255;

signal limSupMuroFrenteC2	:integer:=440;
signal limSupMuroAtrasC2	:integer:=260;
signal limInfMuroAtrasC2	:integer:=270;

signal limExtMuroIzqC2		:integer:=115;
signal limExtMuroDerC2		:integer:=325;
signal limIntMuroDerC2		:integer:=315;
signal limIntMuroIzqC2		:integer:=125;

signal limLPuertaFrenteC2 :integer:=168;
signal limRPuertaFrenteC2 :integer:=182;
signal limSupPuertaPortonC2  :integer:=440;
signal xPuertaFrenteC2    :std_logic_vector(8 downto 0);
signal xPortonC2    		  :std_logic_vector(8 downto 0);

signal limLPuertaFrenteC2aux:std_logic_vector(8 downto 0);
signal limLPortonC2aux:std_logic_vector(8 downto 0);


signal limSupAlbercaC2	:integer:=300;
signal limInfAlbercaC2	:integer:=320;
signal limLAlbercaC2		:integer:=185;
signal limRAlbercaC2		:integer:=255;

signal limLOla1:integer:=195;
signal limROla1:integer:=205;
signal limLOla2:integer:=215;
signal limROla2:integer:=225;
signal limLOla3:integer:=235;
signal limROla3:integer:=245;

signal limOlasSup:integer:=307;
signal limOlasInf:integer:=314;

signal limSupMAlbercaC2	:integer:=290;
signal limInfMAlbercaC2	:integer:=330;
signal limLMAlbercaC2	:integer:=175;
signal limRMAlbercaC2	:integer:=265;

signal limSupCasaC2	:integer:=345;
signal limInfCasaC2	:integer:=420;
signal limLCasaC2		:integer:=155;
signal limRCasaC2		:integer:=285;
--
----***limites de c3******************************************
signal limSupCasaC3	:integer:=325;
signal limInfCasaC3	:integer:=420;
signal limLCasaC3		:integer:=440;
signal limRCasaC3		:integer:=520;
signal limSupBanquetaC3 :integer := 415;

signal limSupVentanasP1C3  :integer:=370;
signal limInfVentanasP1C3  :integer:=395;
signal limSupVentanasP2C3  :integer:=335;
signal limInfVentanasP2C3  :integer:=360;
signal limLVentanasLC3 		:integer:=450;
signal limRVentanasLC3 		:integer:=475;
signal limLVentanasRC3 		:integer:=485;
signal limRVentanasRC3 		:integer:=510;

signal limSupEscalon1C3 :integer:=405;
signal limSupEscalon2C3 :integer:=410;
signal limSupEscalon3C3 :integer:=415;
signal limLEscalones1C3  :integer:=430;
signal limLEscalones2C3  :integer:=420;
signal limLEscalones3C3  :integer:=410;

signal limLMuroFrenteC3 :integer:=380;
signal limRMuroFrenteC3 :integer:=390;
signal limLMuroAtrasC3 :integer:=610;
signal limRMuroAtrasC3 :integer:=620;
signal limSupMurosC3:integer:=390;

signal limSupFarosC3	:integer:=345;
signal limInfFarosC3	:integer:=365;
signal limLFaroFRC3	:integer:=381;
signal limRFaroFRC3	:integer:=389;
signal limLFaroBRC3	:integer:=611;
signal limRFaroBRC3	:integer:=619;

signal limLPosteFRC3	:integer:=383;
signal limRPosteFRC3	:integer:=387;
signal limLPosteBRC3	:integer:=613;
signal limRPosteBRC3	:integer:=617;
--===================================================================================

begin

--Otros-------------------
ledprueba <= ioRx;
ledprueba2 <= ioTx;
ledprueba3 <= paqueteRxcompleto;
--ledprueba3 <= enterPUSHED;
--------------------------

--RELOJES-==========================================================================
clk25MHz: Clks port map(CLK,clk25); --reloj de 25MHz
																			  
sDelay  <= "01011111010111100000111111" when (iRobo='0') else "00000000010011000100101101"; --normal/flash 
msDelay <= "00101111101011110000011111" when (iRobo='0') else "00000000001001100010010110"; --normal/flash


process(CLK)
	begin
		if CLK'event and CLK='1' then
			if cont1seg = sDelay then
				CLK1s <= not CLK1s;
				cont1seg <=(others =>'0');
			else
				cont1seg <= cont1seg+1;
			end if;
		end if;
end process;

process(CLK)
	begin
		if CLK'event and CLK='1' then
			if contMedioSeg = msDelay then
				CLKmedioS <= not CLKmedioS;
				contMedioSeg <=(others =>'0');
			else
				contMedioSeg <= contMedioSeg+1;
			end if;
		end if;
end process;

process(CLK)
	begin
		if CLK'event and CLK='1' then
			if contMov3 = "00000000001001100010010110" then
				clkMov3 <= not clkMov3;
				contMov3 <=(others =>'0');
			else
				contMov3 <= contMov3+1;
			end if;
		end if;
end process;

process(CLK1s)
	begin
		if CLK1s'event and CLK1s='1' then
			if cont1min = 29 then
				CLK1min <= not CLK1min;
				cont1min <=(others =>'0');
			else
				cont1min <= cont1min+1;
			end if;
		end if;
end process;


process(CLK)
	begin
		if CLK'event and CLK='1' then
			if contCuadro = 2 then
				CLKcuadro <= not CLKcuadro;
				contCuadro <=(others =>'0');
			else
				contCuadro <= contCuadro+1;
			end if;
		end if;
end process;


process(CLK) 
begin						
	if(CLK = '1' and CLK'event) then
		clk_lento <= clk_lento + 1;	
	end if;							
end process;

clkMov <= clk_lento(20);	-- reloj para movimiento del dibujo
clkMov2<= clk_lento(19);

--=====================================================================================


--SERIAL-==========================================================================

baud_Timer: process(CLK)
begin
	if CLK'event and CLK='1' then
		if baud_count=650 then
			baud_count<=0;
			en_16_x_baud <='1';
		else
			baud_count<=baud_count + 1;
			en_16_x_baud <='0';
		end if;
	end if;
end process baud_timer;


transmit: uart_tx port map(datoTx,wbufferTx,resetbufferTx,en_16_x_baud,ioTx,bufferFTx,bufferHFTx,CLK);
receive : uart_rx port map(ioRx,datoRx,rbufferRx,resetbufferRx,en_16_x_baud,bufferReadyRx,bufferFRx,bufferHFRx,CLK);

rbufferRx<= bufferReadyRx;

process(CLK)
begin
	if CLK'event and CLK='1' then
			if rbufferRx='1' then
					resetbufferRx='1';
					case(contRx)is
						when "000" => 
											dato55Rx<=datoRx;
											paqueteRxCompleto='0';
						when "001" =>
											datoIdRx<=datoRx;
						when "010" =>
											datoC1Rx<=datoRx;
						when "011" =>
											datoC2Rx<=datoRx;
						when "100" =>
											datoC3Rx<=datoRx;
						when "101" =>
											datoC4Rx<=datoRx;
						when "110" =>
											datoAARx<=datoRx;
											paqueteRxcompleto='1';
						when others => null;
					end case;
			else
					resetbufferRx='0';
			end if;
	end if;
end process;

process(rbufferRx)
begin
	if rbufferRx'event and rbufferRx='1' then
		if contRx="110" then
			contRx<="000";
		else
			contRx<=contRx+'1';
		end if;
	end if;
end process;


process(CLK)
begin
	if CLK'event and CLK='1' then
		if (paqueteRxcompleto='1') then
			dato55Rx<="00000000";
			datoIdRx<="00000000";
			datoC1Rx<="00000000";
			datoC2Rx<="00000000";
			datoC3Rx<="00000000";
			datoC4Rx<="00000000";
			datoAARx<="00000000";
			--paqueteRxCompleto='0';
	end if;
end process;




--=====================================================================================


--DISPLAY del SPARTAN================================================================

disp: Display port map(clk25,disp1,disp2,disp3,disp4,salBCD,ENE);

disp4 <=  datoC1Rx(3 downto 0);
		--	"1011" when (iLuces='1' and iFaros='0') else
       --"1111" when (iLuces='0' and iFaros='1') else 
		--	"1010";

disp3<=	datoC2Rx(3 downto 0);--numeroKB;

disp2<=  datoC3Rx(3 downto 0);
		--	datoTx(7 downto 4) when (transmitting='1') else
		--	datoRx(7 downto 4) when (rbufferRx ='1' ) else
		--	"1010";

disp1<=  dato55Rx(3 downto 0);
		--	datoTx(3 downto 0) when (transmitting='1') else
		--	datoRx(3 downto 0) when (rbufferRx ='1') else
		--	"1010";


process(resetbufferTx,wbufferTx)
begin
	if resetbufferTx='1' then
		transmitting<='0';
	elsif wbufferTx'event and wbufferTx='1' then
		transmitting<='1';
	end if;
end process;


--Lee del TECLADO================================================================
teclado: keyboard port map(kb_clk,kb_data,clk25,resetKB,readKB,kbcode,kbready);

process (clk25,kbready)
begin
  if clk25'EVENT and clk25 = '1' then
		if (kbready = '1')then
			resetKB <= '1';
			readKB  <= '1';
		else
			resetKB <= '0';
			readKB  <= '0';
		end if;
  end if;
end process;


process(clk25, kbready,kbcode)
begin
	if clk25'EVENT and clk25 = '1' then
		if (kbready = '1')then
				case kbcode is
					when "00010110" => numerokb<="0001"; --0x16 1
					when "00011110" => numerokb<="0010"; --0x1E 2
					when "00100110" => numerokb<="0011"; --0x26 3
					when "00100101" => numerokb<="0100"; --0x25 4
					when "00101110" => numerokb<="0101"; --0x2E 5
					when "00110110" => numerokb<="0110"; --0x36 6
					when "00111101" => numerokb<="0111"; --0x3D 7
					when "00111110" => numerokb<="1000"; --0x3E 8
					when "01000110" => numerokb<="1001"; --0x46 9
				--	when "01000101" => numerokb<="0000"; --0x45 0
					when "00101001" => numerokb<="1010"; --0x29 BORRAR
					when others 	 => numerokb<=numerokb;
				end case;
		end if;
  end if;
end process;

process(clk25, kbready,kbcode)
begin
	if clk25'EVENT and clk25 = '1' then
		if (kbready = '1')then
				case kbcode is
					when "11110000" => if enterPUSHED = '1' then --0xF0 soltar tecla
													enterOFF <='1';
											 end if;
					when "01011010" => --ENTER
											if enterOFF = '1' then 
												enterPUSHED <='0';
												enterOFF <= '0';
											else 
												enterPUSHED <='1';
											end if;
					when others 	 => null;
				end case;
		end if;
  end if;
end process;


process(enterPUSHED,numeroKB, iLuces, iFaros)
begin
	if enterPUSHED'EVENT and enterPUSHED= '1' then
		case numeroKB is
					when "0001"=> --1
								  if(iLuces='1' and iFaros='0')then
											intventanaULF<= intventanaULF +'1';
											banderaTodasLucesIgual<='0';
											banderaTodasLucesP2Igual<='0';
								  elsif (iLuces='0' and iFaros='1') then
											intFaroFL<= intFaroFL+'1';
											banderaTodosFarosIgual<='0';
											banderaTodosFarosFIgual<='0';
								  end if;
					when "0010"=> --2
								  if(iLuces='1' and iFaros='0')then
											intventanaURF<= intventanaURF +'1';
											banderaTodasLucesIgual<='0';
											banderaTodasLucesP2Igual<='0';
								  elsif (iLuces='0' and iFaros='1') then
											intFaroFR<= intFaroFR+'1';
											banderaTodosFarosIgual<='0';
											banderaTodosFarosFIgual<='0';
								  end if;
					when "0011"=> --3
					           if(iLuces='1' and iFaros='0')then
											intventanaDLF<= intventanaDLF +'1';
											banderaTodasLucesIgual<='0';
											banderaTodasLucesP1Igual<='0';
								  elsif (iLuces='0' and iFaros='1') then
											intFaroBL<= intFaroBL+'1';
											banderaTodosFarosIgual<='0';
											banderaTodosFarosBIgual<='0';
								  end if;
					when "0100"=> --4
								  if(iLuces='1' and iFaros='0')then
											intventanaDRF<= intventanaDRF +'1';
											banderaTodasLucesIgual<='0';
											banderaTodasLucesP1Igual<='0';
								  elsif (iLuces='0' and iFaros='1') then
											intFaroBR<= intFaroBR+'1';
											banderaTodosFarosIgual<='0';
											banderaTodosFarosBIgual<='0';
								  end if;
					when "0101"=> --5
								  if(iLuces='1' and iFaros='0')then
											intventanaURB<= intventanaURB +'1';	
											banderaTodasLucesIgual<='0';
											banderaTodasLucesP2Igual<='0';
								  end if;
					when "0110"=> --6
								  if(iLuces='1' and iFaros='0')then
											intventanaDRB<= intventanaDRB +'1';	
											banderaTodasLucesP1Igual<='0';
											banderaTodasLucesIgual<='0';
								  end if;
					when "0111"=> --7 --todas primer piso o frente en intensidad1 primero y luego aumenta
								  if(iLuces='1' and iFaros='0')then
										if (banderaTodasLucesP1Igual='0') then
											intventanaDLF<="01";
											intventanaDRF<="01";
											intventanaDRB<="01";
											banderaTodasLucesP1Igual<='1';
										else
											intventanaDLF<= intventanaDLF+'1';
											intventanaDRF<= intventanaDRF+'1';
											intventanaDRB<= intventanaDRB+'1';
										end if;
								  elsif (iLuces='0' and iFaros='1') then
										if (banderaTodosFarosFIgual='0') then
											intFaroFL<= "01";
											intFaroFR<= "01";
											banderaTodosFarosFIgual<='1';
										else
											intFaroFL<= intFaroFL+'1';
											intFaroFR<= intFaroFR+'1';
										end if;
								  end if;
					when "1000"=> --8 --todas segundo piso o atras en intensidad1 primero y luego aumenta
								  if(iLuces='1' and iFaros='0')then
										if (banderaTodasLucesP2Igual='0') then
											intventanaULF<="01";
											intventanaURF<="01";
											intventanaURB<="01";
											banderaTodasLucesP2Igual<='1';
										else
											intventanaULF<= intventanaULF+'1';
											intventanaURF<= intventanaURF+'1';
											intventanaURB<= intventanaURB+'1';
										end if;
								  elsif (iLuces='0' and iFaros='1') then
										if (banderaTodosFarosBIgual='0') then
											intFaroBL<= "01";
											intFaroBR<= "01";
											banderaTodosFarosBIgual<='1';
										else
											intFaroBL<= intFaroBL+'1';
											intFaroBR<= intFaroBR+'1';
										end if;
								  end if;
					when "1001"=> --9 --todas en intensidad1 primero y luego aumenta
								 if(iLuces='1' and iFaros='0')then
										if (banderaTodasLucesIgual='0') then
											intventanaULF<="01";
											intventanaURF<="01";
											intventanaDLF<="01";
											intventanaDRF<="01";
											intventanaURB<="01";
											intventanaDRB<="01";
											banderaTodasLucesIgual<='1';
										else
											intventanaULF<= intventanaULF+'1';
											intventanaURF<= intventanaURF+'1';
											intventanaDLF<= intventanaDLF+'1';
											intventanaDRF<= intventanaDRF+'1';
											intventanaURB<= intventanaURB+'1';
											intventanaDRB<= intventanaDRB+'1';
										end if;
								  elsif (iLuces='0' and iFaros='1') then
										if (banderaTodosFarosIgual='0') then
											intFaroFL<= "01";
											intFaroFR<= "01";
											intFaroBL<= "01";
											intFaroBR<= "01";
											banderaTodosFarosIgual<='1';
										else
											intFaroFL<= intFaroFL+'1';
											intFaroFR<= intFaroFR+'1';
											intFaroBL<= intFaroBL+'1';
											intFaroBR<= intFaroBR+'1';
										end if;
								  end if;

					when others 	 => null;
		end case;
  end if;
end process;



--==================================================================================================

--GENERA SEÑAL de VGA-*=============================================================================

contHcont: contador port map(clk25,resetH,'1',Hcont);
contVcont: contador port map(clk25,resetV,resetH,Vcont);

resetH <= '1' when Hcont = 799 else '0'; --cuando = 799
resetV <= '1' when Vcont = 519 else '0'; --cuando = 519

HSaux <= '1' when ((Hcont < 656) or (Hcont > 752)) else '0'; --<656 o >752
VSaux <= '1' when ((Vcont < 490) or (Vcont > 492)) else '0'; --<490 o >492

HS <= HSaux;
VS <= VSaux;

--==================================================================================================




--Checa BANDERASD de UBICACIóN-=====================================================================

--**generales***************************************************************************
onScreen  <= '1' when (HSaux = '1' and VSaux='1' ) else '0';
onLeftBar <= '1' when (Hcont < limCapsD and onScreen = '1') else '0';
onCap1    <= '1' when (Hcont > limCapsD and Vcont < limCapsMh and onScreen = '1') else '0';
onCap2    <= '1' when (Hcont > limCapsD and Vcont > limCapsMh and Hcont < limCapsMv and onScreen = '1') else '0';
onCap3    <= '1' when (Hcont > limCapsD and Vcont > limCapsMh and Hcont > limCapsMv and onScreen = '1') else '0';
onAnyCap  <= onCap1 or onCap2 or onCap3;

onLeftBarFrame 	 <= '1' when (Hcont = limCapsD) else '0';
onMiddleCapsHFrame <= '1' when (Hcont > limCapsD  and Vcont = limCapsMh and onScreen = '1') else '0';
onMiddleCapsVFrame <= '1' when (Vcont > limCapsMh and Hcont = limCapsMv and onScreen = '1') else '0';
onCapsFrame			 <= onLeftBarFrame or onMiddleCapsHFrame or onMiddleCapsVFrame;
----------------------------------------------------------------------------------------

------**left Bar************************************************************************


interruptorLB<= '1' when(Hcont>limLinterruptorLB and Hcont<limRinterruptorLB and Vcont>limSUPinterruptorLB and Vcont<limINFinterruptorLB) else'0';
onFrameInterruptor <= '1' when (Hcont>limLinterruptorLB and Hcont<limRinterruptorLB and (Vcont=limSUPinterruptorLB or Vcont=limINFinterruptorLB)) else
							 '1' when ((Hcont=limLinterruptorLB or Hcont=limRinterruptorLB) and Vcont>limSUPinterruptorLB and Vcont<limINFinterruptorLB) else '0';

onLetreroON<= onON_o or onON_n ;
onLetreroOFF<= onOFF_o or onOFF_f1 or onOFF_f2 ;

onON_o   <= '1' when (Hcont>=limLON_o and Hcont<limRON_o and Vcont>=limSupLetreroONOFF and Vcont<=limInfLetreroONOFF) else '0';
onON_n   <= '1' when (Hcont>=limLON_n and Hcont< limRON_n and Vcont>=limSupLetreroONOFF and Vcont<=limInfLetreroONOFF) else '0';
onOFF_o  <= '1' when (Hcont>=limLOFF_o and Hcont<limROFF_o and Vcont>=limSupLetreroONOFF and Vcont<=limInfLetreroONOFF) else '0';
onOFF_f1 <= '1' when (Hcont>=limLOFF_f1 and Hcont<limROFF_f1 and Vcont>=limSupLetreroONOFF and Vcont<=limInfLetreroONOFF) else '0';	
onOFF_f2 <= '1' when (Hcont>=limLOFF_f2 and Hcont<limROFF_f2 and Vcont>=limSupLetreroONOFF and Vcont<=limInfLetreroONOFF) else '0';

	  
onHoraLB<= onHrH or onHrL or onMinH or onMinL or on2p;

onHrH <= '1' when (Hcont>=limLhrH and Hcont<limRhrH and Vcont>=limSupHora and Vcont<=limInfHora) else '0';
onHrL <= '1' when (Hcont>=limLhrL and Hcont<limRhrL and Vcont>=limSupHora and Vcont<=limInfHora) else '0';
onMinH<= '1' when (Hcont>=limLminH and Hcont<limRminH and Vcont>=limSupHora and Vcont<=limInfHora) else '0';
onMinL<= '1' when (Hcont>=limLminL and Hcont<limRminL and Vcont>=limSupHora and Vcont<=limInfHora) else '0';	
on2p  <= '1' when (Hcont>=limLdosPuntos and Hcont<limRdosPuntos and Vcont>=limSupHora and Vcont<=limInfHora) else '0';		  


celAntenaLB <= '1' when (Hcont>limLcelCarcazaLB and Hcont<limRcelAntenaLB and Vcont>limSUPcelAntenaLB and Vcont<limSUPcelCarcazaLB) else'0';
celPantallaLB <= '1' when (Hcont>limLcelCarcazaLB+3 and Hcont<limRcelCarcazaLB-3 and Vcont>limSUPcelPantallaLB and Vcont<limINFcelPantallaLB) else '0';
celTecladoLB <= '1' when (Hcont>limLcelCarcazaLB+3 and Hcont<limRcelCarcazaLB-3 and Vcont>limSUPcelTecladoLB and Vcont<limINFcelTecladoLB) else '0';
celCarcazaLB <= '1' when (celTecladoLB='0' and celPantallaLB='0' and Hcont>limLcelCarcazaLB and Hcont<limRcelCarcazaLB and Vcont>limSUPcelCarcazaLB and Vcont<limINFcelCarcazaLB and onFrameCel='0') else '0';
onFrameCel <= '1' when (Hcont>limLcelCarcazaLB and Hcont<limRcelAntenaLB and Vcont=limSUPcelAntenaLB) else
				  '1' when ((Hcont=limLcelCarcazaLB or Hcont=limRcelAntenaLB) and Vcont>limSUPcelAntenaLB and Vcont<limSUPcelCarcazaLB) else
				  '1' when (Hcont>limLcelCarcazaLB+3 and Hcont<limRcelCarcazaLB-3 and (Vcont=limSUPcelPantallaLB or Vcont=limINFcelPantallaLB)) else
				  '1' when ((Hcont=limLcelCarcazaLB+3 or Hcont=limRcelCarcazaLB-3) and Vcont>limSUPcelPantallaLB and Vcont<limINFcelPantallaLB) else
				  '1' when (Hcont>limLcelCarcazaLB+3 and Hcont<limRcelCarcazaLB-3 and (Vcont=limSUPcelTecladoLB or Vcont=limINFcelTecladoLB)) else
				  '1' when ((Hcont=limLcelCarcazaLB+3 or Hcont=limRcelCarcazaLB-3) and Vcont>limSUPcelTecladoLB and Vcont<limINFcelTecladoLB) else
				  '1' when (Hcont>limLcelCarcazaLB and Hcont<limRcelCarcazaLB and (Vcont=limSUPcelCarcazaLB or Vcont=limINFcelCarcazaLB)) else
				  '1' when ((Hcont=limLcelCarcazaLB or Hcont=limRcelCarcazaLB) and Vcont>limSUPcelCarcazaLB and Vcont<limINFcelCarcazaLB) else
				  '0';

lockCentroLB  <= '1' when (Hcont>limLlockCandadoLB+10 and Hcont<limRlockCandadoLB-10 and Vcont>limSUPlockCandadoLB+10 and Vcont<limINFlockCandadoLB-10) else'0';
lockCandadoLB <= '1' when (onFrameLock='0' and lockCentroLB='0' and Hcont>limLlockCandadoLB and Hcont<limRlockCandadoLB and Vcont>limSUPlockCandadoLB and Vcont<limINFlockCandadoLB) else'0';
lockRVarcoLB  <= '1' when (Hcont>limLlockCandadoLB and Hcont< limRlockRVarcoLB and Vcont>=limSUPlockRVarcoLB and Vcont<limSUPlockCandadoLB) else'0';
lockHarcoLB   <= '1' when (Hcont>limLlockCandadoLB and Hcont<limRlockCandadoLB and Vcont>limSUPlockHarcoLB and Vcont<limSUPlockRVarcoLB) else'0';
lockLV1arcoLB <= '1' when (onFrameLock='0' and Hcont>limLlockLVarcoLB and Hcont<limRlockCandadoLB and Vcont>=limSUPlockRVarcoLB and Vcont<= limINFlockLVarcoLB) else'0';
lockLV2arcoLB <= '1' when (iAlarma='1' and Hcont>limLlockLVarcoLB and Hcont<limRlockCandadoLB and Vcont>limINFlockLVarcoLB and Vcont< limSUPlockCandadoLB) else'0';
onFrameLock   <= '1' when (Hcont>limLlockCandadoLB+10 and Hcont<limRlockCandadoLB-10 and (Vcont=limSUPlockCandadoLB+10 or Vcont=limINFlockCandadoLB-10)) else
					  '1' when ((Hcont=limLlockCandadoLB+10 or Hcont=limRlockCandadoLB-10) and Vcont>limSUPlockCandadoLB+10 and Vcont<limINFlockCandadoLB-10) else
					  
					  '1' when (Hcont>limLlockCandadoLB and Hcont<limRlockCandadoLB and (Vcont=limSUPlockCandadoLB or Vcont=limINFlockCandadoLB)) else
					  '1' when ((Hcont=limLlockCandadoLB or Hcont=limRlockCandadoLB) and Vcont>limSUPlockCandadoLB and Vcont<limINFlockCandadoLB) else
					  
					  '1' when (Hcont=limRlockRVarcoLB and Vcont>limSUPlockHarcoLB and Vcont<limSUPlockCandadoLB) else
					  '1' when (Hcont=limLlockCandadoLB and  Vcont>limSUPlockRVarcoLB and Vcont<limSUPlockCandadoLB) else
					  
					  '1' when (Hcont>limLlockCandadoLB and Hcont<limRlockCandadoLB and Vcont=limSUPlockHarcoLB) else
					  '1' when (Hcont>limRlockRVarcoLB  and Hcont<limLlockLVarcoLB  and Vcont=limSUPlockRVarcoLB) else
					  
					  '1' when (Vcont>limSUPlockHarcoLB and Vcont<=limINFlockLVarcoLB and Hcont=limLlockLVarcoLB) else
					  '1' when (Vcont>limSUPlockRVarcoLB and Vcont<=limINFlockLVarcoLB and Hcont=limRlockCandadoLB) else
					  
					  '1' when (iAlarma='1' and Vcont>limINFlockLVarcoLB and Vcont< limSUPlockCandadoLB and Hcont=limRlockCandadoLB) else
					  '1' when (iAlarma='1' and Vcont>limINFlockLVarcoLB and Vcont< limSUPlockCandadoLB and Hcont=limLlockLVarcoLB) else 
					  '1' when (iAlarma='0' and Hcont>limLlockLVarcoLB and Hcont<limRlockCandadoLB and Vcont=limINFlockLVarcoLB+1) else

					  '1' when ((Hcont=limLlockCandadoLB or Hcont=limRlockCandadoLB) and Vcont>limSUPlockHarcoLB and Vcont<=limSUPlockRVarcoLB) else
					  '0';

----------------------------------------------------------------------------------------



------**c1*****************************************************************************
cieloC1 		 <= '1' when (onCap1='1' and anyElementoC1='0' and onFrameC1='0') else '0';
pastoFueraC1 <= '1' when (onCap1='1' and Vcont > limHorizonteC1 and Vcont < limSupBanquetaC1 and Hcont <limLMuroFrente1C1 ) else 
					 '1' when (onCap1='1' and Vcont > limHorizonteC1 and Vcont < limSupBanquetaC1 and Hcont >limRMuroFrente2C1 ) else '0';
banquetaC1 	 <= '1' when (onCap1='1' and Vcont>limSupBanquetaC1 and Vcont<limInfBanquetaC1-3 and Hcont <limLentreBanquetasC1) else 
				    '1' when (onCap1='1' and Vcont>limSupBanquetaC1 and Vcont<limInfBanquetaC1-3 and Hcont >limRentreBanquetasC1) else '0';
bordeBanquetaC1 <= '1' when (onCap1='1' and Vcont>limInfBanquetaC1-3 and Vcont<limInfBanquetaC1 and Hcont <limLentreBanquetasC1) else 
				       '1' when (onCap1='1' and Vcont>limInfBanquetaC1-3 and Vcont<limInfBanquetaC1 and Hcont >limRentreBanquetasC1) else '0';
calleC1      <= '1' when (onCap1='1' and onFrameC1='0' and Vcont>limInfCasaC1 and Vcont <= limSupBanquetaC1 and Hcont >limLentreBanquetasC1 and Hcont <limRentreBanquetasC1 and portonC1='0') else
			       '1' when (onCap1='1' and onFrameC1='0' and Vcont>limSupBanquetaC1 and Vcont <= limInfBanquetaC1 and Hcont >limLentreBanquetasC1 and Hcont <limRentreBanquetasC1) else
					 '1' when (onCap1='1' and Vcont>limInfBanquetaC1) else '0';
			
faroFLc1 <= '1' when (onCap1='1' and Hcont>limLMuroFrente1C1-2 and Hcont<limRPosteFLc1+2 and Vcont>limSupFarosFc1 and Vcont<limSupPostesFc1) else '0';
faroBLc1 <= '1' when (onCap1='1' and Hcont>limLPosteBLc1-2 and Hcont<limRPosteBLc1+2 and Vcont>limSupFarosBc1 and Vcont<limSupPostesBc1) else '0';
faroFRc1 <= '1' when (onCap1='1' and Hcont>limLPosteFRc1-2 and Hcont<limRMuroFrente2C1+2 and Vcont>limSupFarosFc1 and Vcont<limSupPostesFc1) else '0';
faroBRc1 <= '1' when (onCap1='1' and Hcont>limLPosteBRc1-2 and Hcont<limRPosteBRc1+2 and Vcont>limSupFarosBc1 and Vcont<limSupPostesBc1) else '0';
anyFaroC1<= faroFLc1 or faroBLc1 or faroFRc1 or faroBRc1;


posteFLc1 <= '1' when (onCap1='1' and Vcont>limSupPostesFc1 and Vcont<limSupMuroFrenteC1 and Hcont>limLMuroFrente1C1 and Hcont<limRPosteFLc1) else '0';
posteBLc1 <= '1' when (onCap1='1' and Vcont>limSupPostesBc1 and Vcont<limSupMuroAtrasC1 and Hcont>limLPosteBLc1 and Hcont<limRPosteBLc1) else '0';
posteFRc1 <= '1' when (onCap1='1' and Vcont>limSupPostesFc1 and Vcont<limSupMuroFrenteC1 and Hcont>limLPosteFRc1 and Hcont<limRMuroFrente2C1) else '0';
posteBRc1 <= '1' when (onCap1='1' and Vcont>limSupPostesBc1 and Vcont<limSupMuroAtrasC1 and Hcont>limLPosteBRc1 and Hcont<limRPosteBRc1) else '0';
anyPosteC1<= posteFLc1 or posteBLc1 or posteFRc1 or posteBRc1;

muroFc1 <= '1' when (onCap1='1' and Vcont> limSupMuroFrenteC1 and Vcont<limSupBanquetaC1 and Hcont>limLMuroFrente1C1  and Hcont<limRMuroFrente1C1-45 ) else
			  '1' when (onCap1='1' and Vcont> limSupMuroFrenteC1 and Vcont<limSupBanquetaC1 and Hcont>limLMuroFrente2C1+30  and Hcont<limRMuroFrente2C1 ) else '0';

muroFcurvoC1 <= '1' when (onCap1='1' and onFrameC1='0' and Vcont> limSupMuroFrenteC1 and Vcont<limSupBanquetaC1 and Hcont>=limRMuroFrente1C1-45  and Hcont<limRMuroFrente1C1-25 ) else
				    '1' when (onCap1='1' and onFrameC1='0' and Vcont> limSupMuroFrenteC1 and Vcont<limSupBanquetaC1 and Hcont>limLMuroFrente2C1  and Hcont<=limLMuroFrente2C1+30 ) else '0';

muroBc1 <= '1' when (onCap1='1' and Vcont> limSupMuroAtrasC1 and Vcont<limSupMuroFrenteC1 and Hcont>limRPosteFLc1  and Hcont<limRMuroAtras1C1 ) else
			  '1' when (onCap1='1' and Vcont> limSupMuroAtrasC1 and Vcont<limSupMuroFrenteC1 and Hcont>limLMuroAtras2C1  and Hcont<limLPosteFRc1 ) else '0';

paredPuertaFrenteC1 <=  '1' when (onCap1='1' and onFrameC1='0' and Vcont> limSupMuroFrenteC1 and Vcont<limSupBanquetaC1 and Hcont>limRMuroFrente1C1-25 and Hcont<limRMuroFrente1C1-20) else 
								'1' when (onCap1='1' and onFrameC1='0' and Vcont> limSupMuroFrenteC1 and Vcont<limSupBanquetaC1 and Hcont>limRMuroFrente1C1-5 and Hcont<limRMuroFrente1C1) else '0';
				


process(clkMov2)
begin
	if clkMov2='1' and clkMov2'event then
			if(iPorton='0' and limLPortonC1Aux>limLPortonC1 and xPortonC1>"000000000")then
					xPortonC1<= xPortonC1-'1';
			elsif (iPorton='1' and limLPortonC1aux<limRentreBanquetasC1)then
					xPortonC1<= xPortonC1+'1';
			end if;	
	end if;
end process;


process(clkMov2)
begin
	if clkMov='1' and clkMov'event then
		if (iPuerta='0' and limLPuertaFrenteC1aux>limLPuertaFrenteC1) then
			xPuertaFrenteC1<= xPuertaFrenteC1-'1';
		elsif (iPuerta='1' and limLPuertaFrenteC1aux<limRPuertaFrenteC1-2) then
		   xPuertaFrenteC1<= xPuertaFrenteC1+'1';
		end if;
	end if;

end process;



limLPuertaFrenteC1aux<= limLPuertaFrenteC1 + xPuertaFrenteC1;
limLPortonC1aux<= limLPortonC1 + xPortonC1;

puertaFrenteC1 <= '1' when (onCap1='1' and Vcont> limSupMuroFrenteC1 and Vcont<limSupBanquetaC1 and Hcont>limLPuertaFrenteC1aux and Hcont<limRPuertaFrenteC1) else '0';
portonC1 <= '1' when (onCap1='1' and Hcont>limLPortonC1aux and Hcont<limRPortonC1 and Vcont>limSupMuroFrenteC1 and Vcont<limSupBanquetaC1 ) else '0';


puertaCasaC1 <= '1' when (onCap1='1' and Vcont>limSupPuertaCasaC1 and Vcont<limInfFachadaP1C1 and Hcont>limLPuertaCasaC1 and Hcont<limRPuertaCasaC1 and onFrameC1='0' and portonC1='0') else '0';
ventanaULFc1 <= '1' when (onCap1='1' and Vcont>limInfTechoUC1 and Vcont<limInfVentanasP2C1 and Hcont>limIntMuroLcasaC1 and Hcont<limLenMedioVentanasP2C1) else '0';
ventanaURFc1 <= '1' when (onCap1='1' and Vcont>limInfTechoUC1 and Vcont<limInfVentanasP2C1 and Hcont>limRenMedioVentanasP2C1 and Hcont<limIntMuroRcasaC1 ) else '0';
ventanaDLFc1 <= '1' when (onCap1='1' and Vcont>limSupVentanasP1C1 and Vcont<limInfVentanasP1C1 and Hcont>limIntMuroLcasaC1 and Hcont<limLintVentanasP1C1 ) else '0';
ventanaDRFc1 <= '1' when (onCap1='1' and Vcont>limSupVentanasP1C1 and Vcont<limInfVentanasP1C1 and Hcont>limRintVentanasP1C1 and Hcont<limIntMuroRcasaC1 ) else '0';
anyVentanaC1 <= ventanaULFc1 or ventanaURFc1 or ventanaDLFc1 or ventanaDRFc1;
marcoVentanasYpuertaC1 <= '1' when (onCap1='1' and onFrameC1='0' and puertaCasaC1='0'  and portonC1='0' and Vcont>limInfTechoDC1 and Vcont<limInfFachadaP1C1 and Hcont>limLintVentanasP1C1 and Hcont<limRintVentanasP1C1) else '0';

muroLtechoCasaC1  <= '1' when (onCap1='1' and Vcont>limSupAzoteaC1 and Vcont<limInfAzoteaC1 and Hcont>limRMuroAtras1C1 and Hcont< limIntMuroLcasaC1) else '0';
muroLcasaC1 		<= '1' when (onCap1='1' and Vcont>limInfAzoteaC1 and Vcont<limSupMuroFrenteC1 and Hcont>limRMuroAtras1C1 and Hcont< limIntMuroLcasaC1) else '0';
muroRtechoCasaC1  <= '1' when (onCap1='1' and Vcont>limSupAzoteaC1 and Vcont<limInfAzoteaC1 and Hcont>limIntMuroRcasaC1 and Hcont< limLMuroAtras2C1) else '0';
muroRcasaC1 		<= '1' when (onCap1='1' and Vcont>limInfAzoteaC1 and Vcont<limSupMuroFrenteC1 and Hcont>limIntMuroRcasaC1 and Hcont< limLMuroAtras2C1) else '0';

fachadaCasaC1 <= '1' when (onCap1='1' and Vcont> limInfTechoUC1 and Vcont<limInfFachadaP1C1 and Hcont>limIntMuroLcasaC1 and Hcont< limIntMuroRcasaC1 
									and anyVentanaC1='0' and puertaCasaC1='0' and marcoVentanasYpuertaC1='0' and balconUC1='0' and techoUC1='0' and techoDC1='0'
									and onFrameC1='0' and portonC1='0' and muroFcurvoC1='0' and puertaFrenteC1='0' and paredPuertaFrenteC1='0') else '0';
									
azoteaC1 <= '1' when (onCap1='1' and Vcont>limSupAzoteaC1 and Vcont<limInfAzoteaC1 and Hcont>limIntMuroLcasaC1 and Hcont< limIntMuroRcasaC1) else '0';
techoUC1 <= '1' when (onCap1='1' and Vcont>limInfAzoteaC1 and Vcont<limInfTechoUC1 and Hcont>limIntMuroLcasaC1 and Hcont< limIntMuroRcasaC1) else '0';
techoDC1 <= '1' when (onCap1='1' and Vcont>limSupTechoDC1 and Vcont<limInfTechoDC1 and Hcont>limIntMuroLcasaC1 and Hcont< limIntMuroRcasaC1) else '0';
balconUC1 <= '1' when (onCap1='1' and Vcont>limInfFachadaP2C1 and Vcont<limSupTechoDC1 and Hcont>limIntMuroLcasaC1 and Hcont< limIntMuroRcasaC1) else '0';
balconDC1 <= '1' when (onCap1='1' and Vcont>limInfFachadaP1C1 and Vcont<limSupEscalon1C1 and Hcont>limIntMuroLcasaC1 and Hcont< limIntMuroRcasaC1
							  and onFrameC1='0' and portonC1='0' and muroFcurvoC1='0' and puertaFrenteC1='0' and paredPuertaFrenteC1='0') else '0';

escalon1C1<= '1' when (onCap1='1' and onFrameC1='0' and portonC1='0' and Vcont>limSupEscalon1C1 and Vcont<limSupEscalon2C1 and Hcont>limLEscalon1C1 and Hcont< limREscalon1C1) else '0';
escalon2C1<= '1' when (onCap1='1' and onFrameC1='0' and portonC1='0' and Vcont>limSupEscalon2C1 and Vcont<limSupEscalon3C1 and Hcont>limLEscalon2C1 and Hcont< limREscalon2C1) else '0';
escalon3C1<= '1' when (onCap1='1' and onFrameC1='0' and portonC1='0' and Vcont>limSupEscalon3C1 and Vcont<limInfCasaC1     and Hcont>limLEscalon3C1 and Hcont< limREscalon3C1) else '0';
anyEscalonC1 <= escalon1C1 or escalon2C1 or escalon3C1;
fachadaCasaEscalonesC1<= '1' when (onCap1='1' and onFrameC1='0' and Vcont>limSupEscalon1C1 and Vcont<limInfCasaC1 and Hcont>limIntMuroLcasaC1 and Hcont< limIntMuroRcasaC1
							  and portonC1='0' and muroFcurvoC1='0' and puertaFrenteC1='0' and paredPuertaFrenteC1='0' and anyEscalonC1='0') else '0';

pastoDentroC1<= '1' when (onCap1='1' and puertaFrenteC1='0' and onFrameC1='0' and Vcont>limInfCasaC1 and Vcont<limSupBanquetaC1 and Hcont>limRMuroFrente1C1-20 and Hcont<limRMuroFrente1C1-5)else'0';

anyElementoC1<= '1' when (anyVentanaC1='1' or anyPosteC1='1' or anyFaroC1='1' or muroBc1='1') else
					 '1' when (onCap1='1' and Vcont>limSupAzoteaC1-1 and Vcont<limHorizonteC1 and Hcont>limRMuroAtras1C1-1 and Hcont< limLMuroAtras2C1+1 ) else
					 '1' when (onCap1='1' and Vcont> limHorizonteC1-1) else '0';
					 
onFrameC1<= '1' when (Vcont> limSupPostesFc1 and Vcont<limHorizonteC1 and (Hcont=limLMuroFrente1C1 or Hcont=limRMuroFrente2C1 or Hcont=limRPosteFLc1 or Hcont=limLPosteFRc1)) else
				'1' when (Vcont> limSupPostesBc1 and Vcont<limSupMuroAtrasC1 and (Hcont=limLPosteBLc1 or Hcont=limRPosteBLc1 or Hcont=limLPosteBRc1 or Hcont=limRPosteBRc1)) else 
				'1' when (Vcont= limSupMuroAtrasC1 and anyElementoC1='0' and Hcont>limRPosteFLc1 and Hcont<limLPosteFRc1) else 
				'1' when (Vcont> limSupMuroFrenteC1 and Vcont<limSupBanquetaC1 and (Hcont=limRMuroFrente1C1-25 or Hcont=limRMuroFrente1C1-20 or Hcont=limRMuroFrente1C1-5 or Hcont=limRMuroFrente1C1 or Hcont=limRPortonC1)) else
				'1' when (Vcont> limSupFarosFc1 and Vcont<limSupPostesFc1 and (Hcont=limLMuroFrente1C1-2 or Hcont=limRPosteFLc1+2 or Hcont=limLPosteFRc1-2 or Hcont=limRMuroFrente2C1+2 )) else
				'1' when (Vcont> limSupFarosBc1 and Vcont<limSupPostesBc1 and (Hcont=limLPosteBLc1-2 or Hcont=limRPosteBLc1+2 or Hcont=limLPosteBRc1-2 or Hcont=limRPosteBRc1+2)) else
				'1' when (Hcont> limLMuroFrente1C1-2 and Hcont<limRPosteFLc1+2 and (Vcont=limSupFarosFc1 or Vcont=limSupPostesFc1)) else
				'1' when (Hcont> limLPosteBLc1-2 and Hcont<limRPosteBLc1+2 and (Vcont=limSupFarosBc1 or Vcont=limSupPostesBc1)) else
				'1' when (Hcont> limLPosteFRc1-2 and Hcont<limRMuroFrente2C1+2 and (Vcont=limSupFarosFc1 or Vcont=limSupPostesFc1)) else
				'1' when (Hcont> limLPosteBRc1-2 and Hcont<limRPosteBRc1+2 and (Vcont=limSupFarosBc1 or Vcont=limSupPostesBc1)) else
				'1' when (Hcont> limRMuroFrente1C1-45 and Hcont<limRMuroFrente1C1-20 and Vcont=limSupMuroFrenteC1) else
				'1' when (Hcont> limLMuroFrente2C1 and Hcont<limLMuroFrente2C1+30 and Vcont=limSupMuroFrenteC1) else
				'1' when (Vcont= limSupMuroFrenteC1 and Hcont>limRMuroFrente1C1-5 and Hcont<limRMuroFrente1C1) else
				'1' when (Hcont> limIntMuroLcasaC1 and Hcont< limIntMuroRcasaC1 and (Vcont=limInfFachadaP2C1 or Vcont=limSupTechoDC1 or Vcont=limInfTechoDC1) ) else
				'1' when (Vcont = limInfFachadaP1C1 and Hcont>limRMuroFrente1C1-20 and Hcont<limRMuroFrente1C1-5) else
				'1' when (Vcont = limInfFachadaP1C1 and Hcont>limLPortonC1 and Hcont<limRPortonC1 and portonC1='0') else
				'1' when (Vcont = limSupEscalon1C1 and Hcont>limRMuroFrente1C1-20 and Hcont<limRMuroFrente1C1-5) else
				'1' when (Vcont = limSupEscalon1C1 and Hcont>limLPortonC1 and Hcont<limRPortonC1 and portonC1='0') else
				'1' when (Vcont = limInfCasaC1 and Hcont>limRMuroFrente1C1-20 and Hcont<limRMuroFrente1C1-5) else
				'1' when (Vcont = limInfCasaC1 and Hcont>limLPortonC1 and Hcont<limRPortonC1 and portonC1='0') else
				'1' when (portonC1='0' and Vcont=limSupEscalon2C1 and Hcont>limLEscalon2C1 and Hcont< limREscalon2C1) else 
				'1' when (portonC1='0' and Vcont=limSupEscalon3C1 and Hcont>limLEscalon3C1 and Hcont< limREscalon3C1) else 
				'1' when (portonC1='0' and Vcont>limSupEscalon1C1 and Vcont<limSupEscalon2C1 and (Hcont=limLEscalon1C1 or Hcont= limREscalon1C1))else
			   '1' when (portonC1='0' and Vcont>limSupEscalon2C1 and Vcont<limSupEscalon3C1 and (Hcont=limLEscalon2C1 or Hcont=limREscalon2C1))else
				'1' when (portonC1='0' and Vcont>limSupEscalon3C1 and Vcont<limInfCasaC1 and (Hcont=limLEscalon3C1 or Hcont=limREscalon3C1))else
				'1' when (portonC1='0' and Vcont>limSupPuertaCasaC1 and Vcont<limInfFachadaP1C1 and (Hcont=limLPuertaCasaC1 or Hcont=limRPuertaCasaC1))else				
				'1' when (portonC1='0' and Vcont>limInfTechoDC1 and Vcont<limInfFachadaP1C1 and (Hcont=limLintVentanasP1C1 or Hcont=limRintVentanasP1C1))else
				'1' when ((Vcont=limSupVentanasP1C1 or Vcont=limInfVentanasP1C1) and Hcont>limRintVentanasP1C1 and Hcont<limIntMuroRcasaC1) else
				'1' when ((Vcont=limSupVentanasP1C1 or Vcont=limInfVentanasP1C1) and Hcont>limIntMuroLcasaC1 and Hcont<limLintVentanasP1C1 )else
				'1' when (Vcont=limInfVentanasP2C1 and Hcont>limRenMedioVentanasP2C1 and Hcont<limIntMuroRcasaC1)else				
				'1' when (Vcont=limInfVentanasP2C1 and Hcont>limIntMuroLcasaC1 and Hcont<limLenMedioVentanasP2C1)else
				'1' when (Vcont>limInfTechoUC1 and Vcont<limInfVentanasP2C1 and (Hcont=limRenMedioVentanasP2C1 or Hcont=limLenMedioVentanasP2C1))else
				'1' when (Vcont=limSupPuertaCasaC1 and Hcont>limLPuertaCasaC1 and Hcont<limRPuertaCasaC1)else
				'1' when (Hcont>limLPortonC1aux and Hcont<limRPortonC1 and (Vcont=limSupMuroFrenteC1 or Vcont=limSupBanquetaC1))else
				'1' when ((Hcont=limLPortonC1aux or Hcont=limRPortonC1) and Vcont>limSupMuroFrenteC1 and Vcont<limSupBanquetaC1)else
				'1' when (Vcont> limSupMuroFrenteC1 and Vcont<limSupBanquetaC1 and (Hcont=limLPuertaFrenteC1aux or Hcont=limRPuertaFrenteC1))else
				'1' when ((Vcont=limSupMuroFrenteC1 or Vcont=limSupBanquetaC1) and Hcont>limLPuertaFrenteC1aux and Hcont<limRPuertaFrenteC1)else
				'0';

--------------------------------------------------------------------------------------------




----**c2************************************************************************************

calleC2<= '1' when (onCap2='1' and Vcont>limInfCasaC2 and Hcont >limLIntBanquetaC2 and Hcont <limRIntBanquetaC2 and portonC2='0' and  onFrameC2='0') else 
			 '1' when (onCap2='1' and Vcont>limInfBanquetaC2 and onFrameC2='0') else '0';

banquetaC2<= '1' when (onCap2='1' and Vcont>limSupBanquetaC2 and Vcont<limInfBanquetaC2 and (Hcont <limLIntBanquetaC2 or Hcont >limRIntBanquetaC2 )) else '0';


						
process(clkMov)
begin
	if clkMov='1' and clkMov'event then
			if(iPorton='0' and limLPortonC2aux>limLIntBanquetaC2 and xPortonC2>"000000000")then
					xPortonC2<= xPortonC2-'1';
			elsif (iPorton='1' and limLPortonC2aux<limRIntBanquetaC2-2)then
					xPortonC2<= xPortonC2+'1';
			end if;	
	end if;
end process;

process(clkMov)
begin
	if clkMov='1' and clkMov'event then
			if(iPuerta='0' and limLPuertaFrenteC2aux>limLPuertaFrenteC2 and xPuertaFrenteC2>"000000000")then
					xPuertaFrenteC2<= xPuertaFrenteC2-'1';
			elsif (iPuerta='1' and limLPuertaFrenteC2aux< limRPuertaFrenteC2-2)then
					xPuertaFrenteC2<= xPuertaFrenteC2+'1';
			end if;	
	end if;
end process;		
					
limLPortonC2aux<= limLIntBanquetaC2 + xPortonC2;
limLPuertaFrenteC2aux<= limLPuertaFrenteC2 + xPuertaFrenteC2;
						
puertaFrenteC2<= '1' when (onCap2='1'  and Vcont > limSupPuertaPortonC2 and Vcont < limSupBanquetaC2 and Hcont >limLPuertaFrenteC2aux and Hcont <limRPuertaFrenteC2) else '0';
portonC2<= '1'  when (onCap2='1'  and Vcont > limSupPuertaPortonC2 and Vcont < limSupBanquetaC2 and Hcont >limLPortonC2aux and Hcont <limRIntBanquetaC2) else '0';

murosVc2<= '1' when (onCap2='1' and Hcont >limExtMuroIzqC2 and Hcont <limIntMuroIzqC2 and Vcont>limInfMuroAtrasC2 and Vcont<limSupMuroFrenteC2) else 
			  '1' when (onCap2='1' and Hcont >limIntMuroDerC2 and Hcont <limExtMuroDerC2 and Vcont>limInfMuroAtrasC2 and Vcont<limSupMuroFrenteC2) else 
			  '0';
murosHc2<= '1' when (onCap2='1' and  onFrameC2='0' and Hcont >limIntMuroIzqC2 and Hcont <limIntMuroDerC2 and Vcont>limSupMuroAtrasC2 and Vcont<limInfMuroAtrasC2) else 
			  '1' when (onCap2='1' and  onFrameC2='0' and Hcont >limIntMuroIzqC2 and Hcont <limIntMuroDerC2 and Vcont>limSupMuroFrenteC2 and Vcont<limSupBanquetaC2 and puertaFrenteC2 = '0' and portonC2 = '0' and pastoDentroC2 = '0') else 
			  '0';

pastoDentroC2<= '1' when (onCap2='1' and  onFrameC2='0' and azoteaC2='0' and albercaC2 ='0' and marcoAlbercaC2='0' and caminitoC2='0' and 
						        Hcont >limIntMuroIzqC2 and Hcont <limIntMuroDerC2 and Vcont>limInfMuroAtrasC2 and Vcont<limSupMuroFrenteC2) else '0';
pastoFueraC2<= '1' when (onCap2='1' and Vcont<limSupMuroAtrasC2) else 
					'1' when (onCap2='1' and Hcont<limExtMuroIzqC2  and Vcont>=limSupMuroAtrasC2 and Vcont<limSupBanquetaC2) else
					'1' when (onCap2='1' and Hcont>limExtMuroDerC2  and Vcont>=limSupMuroAtrasC2 and Vcont<limSupBanquetaC2) else '0';

azoteaC2<= '1' when (onCap2='1' and Hcont>limLCasaC2 and Hcont< limRCasaC2 and Vcont>limSupCasaC2 and Vcont<limInfCasac2) else '0';
caminitoC2<= '1' when (onCap2='1' and  onFrameC2='0' and Hcont>limLIntBanquetaC2 and Hcont<limRIntBanquetaC2  and Vcont>limInfCasaC2 and Vcont<limSupPuertaPortonC2) else '0';
albercaC2<= '1' when (onCap2='1' and anyOla='0' and Hcont>limLAlbercaC2 and Hcont<limRAlbercaC2 and Vcont>limSupAlbercaC2 and Vcont<limInfAlbercaC2 ) else '0';
marcoAlbercaC2<= '1' when (onCap2='1' and  onFrameC2='0' and albercaC2= '0' and Hcont>limLMAlbercaC2 and Hcont<limRMAlbercaC2 and Vcont>limSupMAlbercaC2 and Vcont<limInfMAlbercaC2 ) else '0';

faroBIc2<= '1' when (onCap2='1' and Hcont >limExtMuroIzqC2 and Hcont <limIntMuroIzqC2 and Vcont>limSupMuroAtrasC2 and Vcont<limInfMuroAtrasC2 ) else '0';
faroBDc2<= '1' when (onCap2='1' and Hcont >limIntMuroDerC2 and Hcont <limExtMuroDerC2 and Vcont>limSupMuroAtrasC2 and Vcont<limInfMuroAtrasC2 ) else '0';
faroFIc2<= '1' when (onCap2='1' and Hcont >limExtMuroIzqC2 and Hcont <limIntMuroIzqC2 and Vcont>limSupMuroFrenteC2 and Vcont<limSupBanquetaC2 ) else '0';
faroFDc2<= '1' when (onCap2='1' and Hcont >limIntMuroDerC2 and Hcont <limExtMuroDerC2 and Vcont>limSupMuroFrenteC2 and Vcont<limSupBanquetaC2) else '0';

ola1<= '1' when(onCap2='1' and Hcont>=limLOla1 and Hcont<limROla1 and Vcont=limOlasSup) else '0';
ola2<= '1' when(onCap2='1' and Hcont>=limLOla2 and Hcont<limROla2 and Vcont=limOlasInf) else '0';
ola3<= '1' when(onCap2='1' and Hcont>=limLOla3 and Hcont<limROla3 and Vcont=limOlasSup) else '0';
ola4<= '1' when(onCap2='1' and Hcont>=limLOla1 and Hcont<limROla1 and Vcont=limOlasInf) else '0';
ola5<= '1' when(onCap2='1' and Hcont>=limLOla2 and Hcont<limROla2 and Vcont=limOlasSup) else '0';
ola6<= '1' when(onCap2='1' and Hcont>=limLOla3 and Hcont<limROla3 and Vcont=limOlasInf) else '0';
anyOla <= ola1 or ola2 or ola3 or ola4 or ola5 or ola6;

onFrameC2 <= '1' when (Vcont > limSupPuertaPortonC2 and Vcont < limSupBanquetaC2 and (Hcont=limLIntBanquetaC2 or Hcont=limRIntBanquetaC2)) else
				 '1' when (Hcont>limLCasaC2 and Hcont< limRCasaC2 and (Vcont=limSupCasaC2 or Vcont=limInfCasac2)) else
				 '1' when ((Hcont=limLCasaC2 or Hcont= limRCasaC2) and Vcont>limSupCasaC2 and Vcont<limInfCasac2) else
				 '1' when (Hcont>limLAlbercaC2 and Hcont<limRAlbercaC2 and (Vcont=limSupAlbercaC2 or Vcont=limInfAlbercaC2)) else
				 '1' when ((Hcont=limLAlbercaC2 or Hcont=limRAlbercaC2) and Vcont>limSupAlbercaC2 and Vcont<limInfAlbercaC2 ) else
				 '1' when (Hcont>limLMAlbercaC2 and Hcont<limRMAlbercaC2 and (Vcont=limSupMAlbercaC2 or Vcont=limInfMAlbercaC2)) else
				 '1' when ((Hcont=limLMAlbercaC2 or Hcont=limRMAlbercaC2) and Vcont>limSupMAlbercaC2 and Vcont<limInfMAlbercaC2)else
				 '1' when (Vcont > limSupPuertaPortonC2 and Vcont < limSupBanquetaC2 and (Hcont =limLPuertaFrenteC2 or Hcont =limLPuertaFrenteC2aux or Hcont=limRPuertaFrenteC2))else
				 '1' when ((Vcont=limSupPuertaPortonC2 or Vcont=limSupBanquetaC2) and Hcont >limLPuertaFrenteC2aux and Hcont <limRPuertaFrenteC2)else
				 '1' when (Vcont > limSupPuertaPortonC2 and Vcont < limSupBanquetaC2 and (Hcont=limLPortonC2aux or Hcont=limRIntBanquetaC2))else
				 '1' when ((Vcont = limSupPuertaPortonC2 or Vcont = limSupBanquetaC2) and Hcont >limLPortonC2aux and Hcont <limRIntBanquetaC2)else
				 '0';

-------------------------------------------------------------------------------------------



----**c3************************************************************************************
cieloC3<= '1' when (onCap3='1' and pastoFueraC3='0' and banquetaC3='0' and murosVc3='0' and muroHc3='0' 
										 and muroRcasaC3='0' and anyVentanaC3='0' and anyEscalonC3='0' and posteFRc3='0' 
										 and posteBRc3='0' and faroFRc3='0' and faroBRc3='0' and  onFrameC3='0') else '0';
pastoFueraC3<= '1' when (onCap3='1' and Vcont>limInfCasaC3) else '0';

banquetaC3<= '1' when (onCap3='1' and Vcont<limInfCasaC3 and Vcont>limSupBanquetaC3 and Hcont<limLMuroFrenteC3) else '0';

murosVc3<= '1' when (onCap3='1' and Vcont>limSupMurosC3 and Vcont<limInfCasaC3 and Hcont>limLMuroFrenteC3 and Hcont<limRMuroFrenteC3) else 
			  '1' when (onCap3='1' and Vcont>limSupMurosC3 and Vcont<limInfCasaC3 and Hcont>limLMuroAtrasC3 and Hcont<limRMuroAtrasC3) else '0';
muroHc3<=  '1' when (onCap3='1' and  onFrameC3='0' and Vcont>limSupMurosC3 and Vcont<limInfCasaC3 and Hcont>limRMuroFrenteC3 and Hcont<limLCasaC3 and anyEscalonC3='0') else
			  '1' when (onCap3='1' and Vcont>limSupMurosC3 and Vcont<limInfCasaC3 and Hcont>limRCasaC3 and Hcont<limLMuroAtrasC3 ) else '0';
muroRcasaC3<= '1' when (onCap3='1' and  onFrameC3='0' and Vcont>limSupCasaC3 and Vcont<limInfCasaC3 and Hcont>limLCasaC3 and Hcont<limRCasaC3 and anyVentanaC3='0') else '0';

faroFRc3 <= '1' when (onCap3='1' and Vcont>limSupFarosC3 and Vcont<limInfFarosC3 and Hcont>limLFaroFRC3 and Hcont<limRFaroFRC3) else '0';
faroBRc3 <= '1' when (onCap3='1' and Vcont>limSupFarosC3 and Vcont<limInfFarosC3 and Hcont>limLFaroBRC3 and Hcont<limRFaroBRC3) else '0';
posteFRc3<= '1' when (onCap3='1' and Vcont>limInfFarosC3 and Vcont<limSupMurosC3 and Hcont>limLPosteFRC3 and Hcont<limRPosteFRC3) else '0';
posteBRc3<= '1' when (onCap3='1' and Vcont>limInfFarosC3 and Vcont<limSupMurosC3 and Hcont>limLPosteBRC3 and Hcont<limRPosteBRC3) else '0';

ventanaURFc3<= '1' when (onCap3='1' and Hcont>limLVentanasLC3 and Hcont<limRVentanasLC3 and Vcont<limInfVentanasP2C3 and Vcont> limSupVentanasP2C3) else '0';
ventanaURBc3<= '1' when (onCap3='1' and Hcont>limLVentanasRC3 and Hcont<limRVentanasRC3 and Vcont<limInfVentanasP2C3 and Vcont> limSupVentanasP2C3) else '0';
ventanaDRFc3<= '1' when (onCap3='1' and Hcont>limLVentanasLC3 and Hcont<limRVentanasLC3 and Vcont<limInfVentanasP1C3 and Vcont> limSupVentanasP1C3) else '0'; 
ventanaDRBc3<= '1' when (onCap3='1' and Hcont>limLVentanasRC3 and Hcont<limRVentanasRC3 and Vcont<limInfVentanasP1C3 and Vcont> limSupVentanasP1C3) else '0';
anyVentanaC3<= ventanaURFc3 or ventanaURBc3 or ventanaDRFc3 or ventanaDRBc3;

escalon1c3<= '1' when (onCap3='1' and  onFrameC3='0' and Hcont<=limLCasaC3 and Hcont>limLEscalones1C3 and Vcont>limSupEscalon1C3 and Vcont<limSupEscalon2C3) else '0';
escalon2c3<= '1' when (onCap3='1' and  onFrameC3='0' and Hcont<=limLCasaC3 and Hcont>limLEscalones2C3 and Vcont>=limSupEscalon2C3 and Vcont<=limSupEscalon3C3) else '0';
escalon3c3<= '1' when (onCap3='1' and  onFrameC3='0' and Hcont<=limLCasaC3 and Hcont>limLEscalones3C3 and Vcont>limSupEscalon3C3 and Vcont<limInfCasaC3) else '0';
anyEscalonC3<= escalon1C3 or escalon2C3 or escalon3C3;

onFrameC3<= '1' when (onCap3='1' and Vcont=limInfCasaC3) else
				'1' when (Vcont=limSupMurosC3 and Hcont>limLMuroFrenteC3 and Hcont<limLCasaC3) else
				'1' when (Vcont=limSupMurosC3 and Hcont>limRCasaC3 and Hcont<limRMuroAtrasC3) else
				
				'1' when (Vcont>limSupCasaC3 and Vcont<limInfCasaC3 and (Hcont=limLCasaC3 or Hcont=limRCasaC3)) else
				'1' when ((Vcont=limSupCasaC3 or Vcont=limInfCasaC3) and Hcont>limLCasaC3 and Hcont<limRCasaC3) else
				
				'1' when (onCap3='1' and  Vcont=limSupBanquetaC3 and Hcont<limLMuroFrenteC3) else
				'1' when (Vcont>limSupMurosC3 and Vcont<limInfCasaC3 and(Hcont=limLMuroFrenteC3 or Hcont=limRMuroFrenteC3 or Hcont=limLMuroAtrasC3 or Hcont=limRMuroAtrasC3 or Hcont=limLCasaC3 or Hcont=limRCasaC3 )) else
				
				'1' when (Vcont>limInfFarosC3 and Vcont<limSupMurosC3 and (Hcont=limLPosteFRC3 or Hcont=limRPosteFRC3 or Hcont=limLPosteBRC3 or Hcont=limRPosteBRC3)) else
				'1' when ((Vcont=limInfFarosC3 or Vcont=limSupMurosC3) and Hcont>limLPosteFRC3 and Hcont<limRPosteFRC3) else
				'1' when ((Vcont=limInfFarosC3 or Vcont=limSupMurosC3) and Hcont>limLPosteBRC3 and Hcont<limRPosteBRC3) else
				
				'1' when (Vcont>limSupFarosC3 and Vcont<limInfFarosC3 and (Hcont=limLFaroFRC3 or Hcont=limRFaroFRC3 or Hcont=limLFaroBRC3 or Hcont=limRFaroBRC3)) else
				'1' when ((Vcont=limSupFarosC3 or Vcont=limInfFarosC3) and Hcont>limLFaroFRC3 and Hcont<limRFaroFRC3) else
				'1' when ((Vcont=limSupFarosC3 or Vcont=limInfFarosC3) and Hcont>limLFaroBRC3 and Hcont<limRFaroBRC3) else
				
				'1' when (Hcont>limLVentanasLC3 and Hcont<limRVentanasLC3 and (Vcont=limInfVentanasP1C3 or Vcont=limSupVentanasP1C3)) else
				'1' when (Hcont>limLVentanasRC3 and Hcont<limRVentanasRC3 and (Vcont=limInfVentanasP1C3 or Vcont=limSupVentanasP1C3)) else
				'1' when ((Hcont=limLVentanasRC3 or Hcont=limRVentanasRC3 or Hcont=limLVentanasLC3 or Hcont=limRVentanasLC3) and Vcont<limInfVentanasP1C3 and Vcont> limSupVentanasP1C3) else
				
				'1' when (Hcont>limLVentanasLC3 and Hcont<limRVentanasLC3 and (Vcont=limInfVentanasP2C3 or Vcont=limSupVentanasP2C3)) else
				'1' when (Hcont>limLVentanasRC3 and Hcont<limRVentanasRC3 and (Vcont=limInfVentanasP2C3 or Vcont=limSupVentanasP2C3)) else
				'1' when ((Hcont=limLVentanasRC3 or Hcont=limRVentanasRC3 or Hcont=limLVentanasLC3 or Hcont=limRVentanasLC3) and Vcont<limInfVentanasP2C3 and Vcont> limSupVentanasP2C3) else
				
				'1'  when (Hcont<limLCasaC3 and Hcont>limLEscalones1C3 and Vcont=limSupEscalon1C3) else
				'1'  when (Hcont=limLEscalones1C3 and Vcont>limSupEscalon1C3 and Vcont<limSupEscalon2C3) else
				
				'1'  when (Hcont<=limLEscalones1C3 and Hcont>limLEscalones2C3 and Vcont=limSupEscalon2C3) else
				'1'  when (Hcont=limLEscalones2C3 and Vcont>limSupEscalon2C3 and Vcont<limSupEscalon3C3) else
				
				'1'  when (Hcont<=limLEscalones2C3 and Hcont>limLEscalones3C3 and Vcont=limSupEscalon3C3) else
				'1'  when (Hcont=limLEscalones3C3 and Vcont>limSupEscalon3C3 and Vcont<limInfCasaC3) else
				
				'0';

--============================================================================


--Trae de MEMORIA los digitos=================================================

HrHGEN:  testram port map (hrH_address, hrH);
HrLGEN:  testram port map (hrL_address, hrL);
MinHGEN: testram port map (minH_address, minH);
MinLGEN: testram port map (minL_address, minL);
DosPuntosGEN: testram port map (dosPuntos_address, dosPuntos);

     ----calcula la address de RAM de los digitos 
process(Vcont)
begin
	if ((Vcont >=limSupHora) and (Vcont <=limInfHora)) then
		hrH_address(2 downto 0) <= Vcont - limSupHora;  --de 0 a 7
		hrL_address(2 downto 0) <= Vcont - limSupHora;  --de 0 a 7
		minH_address(2 downto 0)<= Vcont - limSupHora;  --de 0 a 7
		minL_address(2 downto 0)<= Vcont - limSupHora;  --de 0 a 7
		dosPuntos_address(2 downto 0) <= Vcont - limSupHora;  --de 0 a 7
	else
		hrH_address(2 downto 0) <= "000";
		hrL_address(2 downto 0) <= "000";
		minH_address(2 downto 0) <= "000";
		minL_address(2 downto 0) <= "000";
		dosPuntos_address(2 downto 0) <= "000";
	end if;
end process;

hrH_address(6 downto 3)  <= contHrH(3 downto 0);
hrL_address(6 downto 3)  <= contHrL(3 downto 0);
minH_address(6 downto 3) <= contMinH(3 downto 0);
minL_address(6 downto 3) <= contMinL(3 downto 0);
dosPuntos_address(6 downto 3) <= "1010" when (CLK1s='1') else "1011";


	  --Calcula Hora------------------------------

process(CLK)
begin
if CLK='1' and CLK'event then
	if (contHrL(3)='1' and contHrL(0)='1' and resetMinH='1')then
			resetHrL<='1';
	elsif (contHrL(1)='1' and contHrL(0)='1' and contHrH(1)='1' and resetMinH='1') then
			resetHrL<='1';
	else  
			resetHrL<='0';
	end if;
end if;
end process;

resetMinL <= contMinL(3) and contMinL(0); --cuando llega a 9
resetMinH <= contMinH(2) and contMinH(0) and resetMinL; --cuando llega a 5
resetHrH  <= '1' when (contHrH(1)='1' and resetHrL='1' ) else '0';--cuando está en 2 y la HrLow se reseta

contadorMinLow:  contador port map(CLK1min,resetMinL ,'1',contMinL);
contadorMinHigh: contador port map(CLK1min,resetMinH,resetMinL ,contMinH);
contadorHrLow:   contador port map(CLK1min,resetHrL,resetMinH,contHrL);
contadorHrHigh:  contador port map(CLK1min,resetHrH,resetHrL,contHrH);
 
--============================================================================================


--***Trae de MEMORIA el letrerito ON/OFF======================================================
     
	  
onO_GEN:   testram port map (onO_address, onO);
onN_GEN:   testram port map (onN_address, onN);
offO_GEN:  testram port map (offO_address, offO);
offF1_GEN: testram port map (offF1_address, offF1);
offF2_GEN: testram port map (offF2_address, offF2);
  
	   ----calcula la address de RAM del letrerito ON/OFF
process(Vcont)
begin
	if ((Vcont >=limSupLetreroONOFF) and (Vcont <=limInfLetreroONOFF)) then
		onO_address(2 downto 0)   <= Vcont - limSupLetreroONOFF;  --de 0 a 7
		onN_address(2 downto 0)   <= Vcont - limSupLetreroONOFF;  --de 0 a 7
		offO_address(2 downto 0)  <= Vcont - limSupLetreroONOFF;  --de 0 a 7
		offF1_address(2 downto 0) <= Vcont - limSupLetreroONOFF;  --de 0 a 7
		offF2_address(2 downto 0) <= Vcont - limSupLetreroONOFF;  --de 0 a 7
	else
		onO_address(2 downto 0)  <= "000";
		onN_address(2 downto 0)  <= "000";
		offO_address(2 downto 0) <= "000";
		offF1_address(2 downto 0)<= "000";
		offF2_address(2 downto 0)<= "000";
	end if;
end process;

onO_address(6 downto 3)  <= "0000";
onN_address(6 downto 3)  <= "1100";
offO_address(6 downto 3) <= "0000";
offF1_address(6 downto 3)<= "1101";
offF2_address(6 downto 3)<= "1101";

--===========================================================================================




--Calcula Colores de cosas===================================================================

--color del Reloj de LEFT BAR***************************************

RGBhrH  <= "111111111111" when (hrH(3)='1' and Hcont(1 downto 0)="10" and contHrH>0) else
			  "111111111111" when (hrH(2)='1' and Hcont(1 downto 0)="11" and contHrH>0) else
			  "111111111111" when (hrH(1)='1' and Hcont(1 downto 0)="00" and contHrH>0) else
			  "111111111111" when (hrH(0)='1' and Hcont(1 downto 0)="01" and contHrH>0) else
			  "000000000000"; --pinta blanco los 1's  y de negro los 0's para que se aprecie el digito
			  
RGBhrL  <= "111111111111" when (hrL(3)='1' and Hcont(1 downto 0)="11") else
			  "111111111111" when (hrL(2)='1' and Hcont(1 downto 0)="00") else
			  "111111111111" when (hrL(1)='1' and Hcont(1 downto 0)="01") else
			  "111111111111" when (hrL(0)='1' and Hcont(1 downto 0)="10") else
			  "000000000000";--pinta blanco los 1's  y de negro los 0's para que se aprecie el digito
			  
RGBminH <= "111111111111" when (minH(3)='1' and Hcont(1 downto 0)="01") else
			  "111111111111" when (minH(2)='1' and Hcont(1 downto 0)="10") else
			  "111111111111" when (minH(1)='1' and Hcont(1 downto 0)="11") else
			  "111111111111" when (minH(0)='1' and Hcont(1 downto 0)="00") else
			  "000000000000";--pinta blanco los 1's  y de negro los 0's para que se aprecie el digito
			  
RGBminL <= "111111111111" when (minL(3)='1' and Hcont(1 downto 0)="10") else
			  "111111111111" when (minL(2)='1' and Hcont(1 downto 0)="11") else
			  "111111111111" when (minL(1)='1' and Hcont(1 downto 0)="00") else
			  "111111111111" when (minL(0)='1' and Hcont(1 downto 0)="01") else
			  "000000000000";--pinta blanco los 1's  y de negro los 0's para que se aprecie el digito
			  
RGB2p  <=  "111111111111" when (dosPuntos(3)='1' and Hcont(1 downto 0)="00") else
			  "111111111111" when (dosPuntos(2)='1' and Hcont(1 downto 0)="01") else
			  "111111111111" when (dosPuntos(1)='1' and Hcont(1 downto 0)="10") else
			  "111111111111" when (dosPuntos(0)='1' and Hcont(1 downto 0)="11") else
			  "000000000000";--pinta blanco los 1's  y de negro los 0's para que se aprecie el digito
			  
--color del letrero ON/OFF e interruptor******************************

RGBonO  <=       RGBLetreroONverde when (onO(3)='1' and Hcont(1 downto 0)="10" and iSistema='1') else
					  RGBLetreroONverde when (onO(2)='1' and Hcont(1 downto 0)="11" and iSistema='1') else
			        RGBLetreroONverde when (onO(1)='1' and Hcont(1 downto 0)="00" and iSistema='1') else
			        RGBLetreroONverde when (onO(0)='1' and Hcont(1 downto 0)="01" and iSistema='1') else
					  "111111111111"    when (onO(3)='1' and Hcont(1 downto 0)="10" and iSistema='0') else
					  "111111111111"    when (onO(2)='1' and Hcont(1 downto 0)="11" and iSistema='0') else
			        "111111111111"    when (onO(1)='1' and Hcont(1 downto 0)="00" and iSistema='0') else
			        "111111111111"    when (onO(0)='1' and Hcont(1 downto 0)="01" and iSistema='0') else
					  "000000000000";
					  
RGBonN  <= 		  RGBLetreroONverde when (onN(3)='1' and Hcont(1 downto 0)="11" and iSistema='1') else
					  RGBLetreroONverde when (onN(2)='1' and Hcont(1 downto 0)="00" and iSistema='1') else
			        RGBLetreroONverde when (onN(1)='1' and Hcont(1 downto 0)="01" and iSistema='1') else
			        RGBLetreroONverde when (onN(0)='1' and Hcont(1 downto 0)="10" and iSistema='1') else
					  "111111111111" 	  when (onN(3)='1' and Hcont(1 downto 0)="11" and iSistema='0') else
					  "111111111111"    when (onN(2)='1' and Hcont(1 downto 0)="00" and iSistema='0') else
			        "111111111111"    when (onN(1)='1' and Hcont(1 downto 0)="01" and iSistema='0') else
			        "111111111111"    when (onN(0)='1' and Hcont(1 downto 0)="10" and iSistema='0') else
			        "000000000000";
			  

RGBoffO <= 		  RGBLetreroOFFrojo when (offO(3)='1' and Hcont(1 downto 0)="01" and iSistema='0') else
			        RGBLetreroOFFrojo when (offO(2)='1' and Hcont(1 downto 0)="10" and iSistema='0') else
					  RGBLetreroOFFrojo when (offO(1)='1' and Hcont(1 downto 0)="11" and iSistema='0') else
			        RGBLetreroOFFrojo when (offO(0)='1' and Hcont(1 downto 0)="00" and iSistema='0') else
					  "111111111111"    when (offO(3)='1' and Hcont(1 downto 0)="01" and iSistema='1') else
			        "111111111111"    when (offO(2)='1' and Hcont(1 downto 0)="10" and iSistema='1') else
					  "111111111111"    when (offO(1)='1' and Hcont(1 downto 0)="11" and iSistema='1') else
			        "111111111111"    when (offO(0)='1' and Hcont(1 downto 0)="00" and iSistema='1') else
					  "000000000000";
					  
RGBoffF1 <=		  RGBLetreroOFFrojo when (offF1(3)='1' and Hcont(1 downto 0)="10" and iSistema='0') else
			        RGBLetreroOFFrojo when (offF1(2)='1' and Hcont(1 downto 0)="11" and iSistema='0') else
			        RGBLetreroOFFrojo when (offF1(1)='1' and Hcont(1 downto 0)="00" and iSistema='0') else
			        RGBLetreroOFFrojo when (offF1(0)='1' and Hcont(1 downto 0)="01" and iSistema='0') else
					  "111111111111"	  when (offF1(3)='1' and Hcont(1 downto 0)="10" and iSistema='1') else
					  "111111111111" 	  when (offF1(2)='1' and Hcont(1 downto 0)="11" and iSistema='1') else
			        "111111111111" 	  when (offF1(1)='1' and Hcont(1 downto 0)="00" and iSistema='1') else
			        "111111111111" 	  when (offF1(0)='1' and Hcont(1 downto 0)="01" and iSistema='1') else	
					  "000000000000";
					  
RGBofff2 <=		  RGBLetreroOFFrojo when (offF2(3)='1' and Hcont(1 downto 0)="11" and iSistema='0') else
			        RGBLetreroOFFrojo when (offF2(2)='1' and Hcont(1 downto 0)="00" and iSistema='0') else
			        RGBLetreroOFFrojo when (offF2(1)='1' and Hcont(1 downto 0)="01" and iSistema='0') else
			        RGBLetreroOFFrojo when (offF2(0)='1' and Hcont(1 downto 0)="10" and iSistema='0') else
					  "111111111111" 	  when (offF2(3)='1' and Hcont(1 downto 0)="11" and iSistema='1') else
					  "111111111111" 	  when (offF2(2)='1' and Hcont(1 downto 0)="00" and iSistema='1') else
			        "111111111111" 	  when (offF2(1)='1' and Hcont(1 downto 0)="01" and iSistema='1') else
			        "111111111111" 	  when (offF2(0)='1' and Hcont(1 downto 0)="10" and iSistema='1') else	
					  "000000000000";
			  
RGBinterruptor <= RGBLetreroONverde when(iSistema='1')else RGBLetreroOFFrojo;

--color del celular*************************

RGBcelularAux <= "111111111111" when (CLKmedioS='1') else "000000000111"; --alterna entre rojo y azul
RGBcelular <= RGBcelularAux when (iAlarma='1' and iRobo='1' and iSistema='1') else "010101010101"; --colorEmergencia/colorNormal(gris)
RGBcelPantalla<= "000010110001";
RGBcelTeclado<=  "011001100011";

--color del candado**************************

RGBlockCentro <= "101010100011";
RGBlockArco   <= "010101010101";
RGBlockCandado<= "000011110000" when (iAlarma='1' and iRobo='0' and iSistema='1') else
                 "111100000000" when (iAlarma='1' and iRobo='1' and iSistema='1') else
					  "111111111111";
					

--color de olas******************************

RGBolasOFFaux <= RGBalbercaC2   when (clkMov3='1') else "100010000110";
RGBolasONaux  <= "100010000110" when (clkMov3='1') else RGBalbercaC2;

RGBolasOFF<= "100010000110" when (iAlberca='0')else RGBolasOFFaux;
RGBolasON <= RGBalbercaC2 when (iAlberca='0')else RGBolasONaux;


--color de intensidades******************************
--==faros==

RGBfaroFLc1<= "111011101110" when (intFaroFL="00") else
				  "001100110000" when (intFaroFL="01") else
				  "011101110000" when (intFaroFL="10") else
				  "111111110000" when (intFaroFL="11") else
				  "000000000000";

RGBfaroFLc2<= "111011101110" when (intFaroFL="00") else
				  "001100110000" when (intFaroFL="01") else
				  "011101110000" when (intFaroFL="10") else
				  "111111110000" when (intFaroFL="11") else
				  "000000000000";
-----
RGBfaroFRc1<= "111011101110" when (intFaroFR="00") else
				  "001100110000" when (intFaroFR="01") else
				  "011101110000" when (intFaroFR="10") else
				  "111111110000" when (intFaroFR="11") else
				  "000000000000";

RGBfaroFRc2<= "111011101110" when (intFaroFR="00") else
				  "001100110000" when (intFaroFR="01") else
				  "011101110000" when (intFaroFR="10") else
				  "111111110000" when (intFaroFR="11") else
				  "000000000000";

RGBfaroFRc3<= "111011101110" when (intFaroFR="00") else
				  "001100110000" when (intFaroFR="01") else
				  "011101110000" when (intFaroFR="10") else
				  "111111110000" when (intFaroFR="11") else
				  "000000000000";
----
RGBfaroBLc1<= "111011101110" when (intFaroBL="00") else
				  "001100110000" when (intFaroBL="01") else
				  "011101110000" when (intFaroBL="10") else
				  "111111110000" when (intFaroBL="11") else
				  "000000000000";

RGBfaroBLc2<= "111011101110" when (intFaroBL="00") else
				  "001100110000" when (intFaroBL="01") else
				  "011101110000" when (intFaroBL="10") else
				  "111111110000" when (intFaroBL="11") else
				  "000000000000";
--
RGBfaroBRc1<= "111011101110" when (intFaroBR="00") else
				  "001100110000" when (intFaroBR="01") else
				  "011101110000" when (intFaroBR="10") else
				  "111111110000" when (intFaroBR="11") else
				  "000000000000";

RGBfaroBRc2<= "111011101110" when (intFaroBR="00") else
				  "001100110000" when (intFaroBR="01") else
				  "011101110000" when (intFaroBR="10") else
				  "111111110000" when (intFaroBR="11") else
				  "000000000000";

RGBfaroBRc3<= "111011101110" when (intFaroBR="00") else
				  "001100110000" when (intFaroBR="01") else
				  "011101110000" when (intFaroBR="10") else
				  "111111110000" when (intFaroBR="11") else
				  "000000000000";
----
--==ventanas==

RGBventanaULFc1<="111011101110" when (intventanaULF="00" or
												 (paqueteRxcompleto='1' and datoC1Rx="00000001" and datoC2Rx="00000001" and datoC3Rx="00000000")) else
					  "001100110000" when (intventanaULF="01" or
												 (paqueteRxcompleto='1' and datoC1Rx="00000001" and datoC2Rx="00000001" and datoC3Rx="00000001")) else
					  "011101110000" when (intventanaULF="10" or
												 (paqueteRxcompleto='1' and datoC1Rx="00000001" and datoC2Rx="00000001" and datoC3Rx="00000010")) else
					  "111111110000" when (intventanaULF="11" or
												 (paqueteRxcompleto='1' and datoC1Rx="00000001" and datoC2Rx="00000001" and datoC3Rx="00000011")) else
					  "000000000000";


---					  
RGBventanaURFc1<="111011101110" when (intventanaURF="00") else
					  "001100110000" when (intventanaURF="01") else
					  "011101110000" when (intventanaURF="10") else
					  "111111110000" when (intventanaURF="11") else
					  "000000000000";	
					  
RGBventanaURFc3<="111011101110" when (intventanaURF="00") else
					  "001100110000" when (intventanaURF="01") else
					  "011101110000" when (intventanaURF="10") else
					  "111111110000" when (intventanaURF="11") else
					  "000000000000";	

---			  
RGBventanaDLFc1<="111011101110" when (intventanaDLF="00") else
					  "001100110000" when (intventanaDLF="01") else
					  "011101110000" when (intventanaDLF="10") else
					  "111111110000" when (intventanaDLF="11") else
					  "000000000000";	


---					  
RGBventanaDRFc1<="111011101110" when (intventanaDRF="00") else
					  "001100110000" when (intventanaDRF="01") else
					  "011101110000" when (intventanaDRF="10") else
					  "111111110000" when (intventanaDRF="11") else
					  "000000000000"; 

RGBventanaDRFc3<="111011101110" when (intventanaDRF="00") else
					  "001100110000" when (intventanaDRF="01") else
					  "011101110000" when (intventanaDRF="10") else
					  "111111110000" when (intventanaDRF="11") else
					  "000000000000"; 

---					  
RGBventanaDRBc3<="111011101110" when (intventanaDRB="00") else
					  "001100110000" when (intventanaDRB="01") else
					  "011101110000" when (intventanaDRB="10") else
					  "111111110000" when (intventanaDRB="11") else
					  "000000000000";


---					  
RGBventanaURBc3<="111011101110" when (intventanaURB="00") else
					  "001100110000" when (intventanaURB="01") else
					  "011101110000" when (intventanaURB="10") else
					  "111111110000" when (intventanaURB="11") else
					  "000000000000";




---------

process(CLK25)
	begin
		if clk25'event and clk25='1' then
			RGBporton(4) <= not RGBporton(4);
			RGBporton(9 downto 8) <= RGBporton(11 downto 8) + '1';
			RGBAux(9) <= not RGBAux(9);
			RGBAux(5) <= not RGBAux(5);
			RGBAux(1) <= not RGBAux(1);
		end if;
end process;


process(CLKcuadro)
	begin
		if CLKcuadro'event and CLKcuadro='1' then
			RGBmuroFC1(11 downto 10)<= RGBmuroFC1(11 downto 10) + '1';
			RGBmuroBC1(9 downto 8) <= RGBmuroBC1(9 downto 8) + '1';
		end if;
end process;

process(CLK)
	begin
		if CLK'event and CLK='1' then
			RGBalbercaC2(5 downto 4) <= RGBalbercaC2(5 downto 4) + '1';
			RGBfachadaCasa(3 downto 0) <= RGBfachadaCasa(3 downto 0)+'1';
		end if;
end process;

--======================================================================

--GENERA Salidas auxiliares de RGB de cada CAP==========================


RGBc1<= RGBcalleC1 when (calleC1='1') else 
		  RGBbanquetaC1 when (banquetaC1='1') else
		  RGBbordeBanquetaC1 when (bordeBanquetaC1='1') else
		  RGBpastoFueraC1 when (pastoFueraC1='1') else
		  RGBfaroFLc1 when (faroFLc1='1')else
	     RGBfaroFRc1 when (faroFRc1='1')else
		  RGBfaroBLc1 when (faroBLc1='1')else
	     RGBfaroBRc1 when (faroBRc1='1')else
		  RGBanyPoste when (anyPosteC1='1') else
		  RGBporton when (portonC1='1' or puertaFrenteC1='1') else
		  RGBparedPuertaFrenteC1 when (paredPuertaFrenteC1='1') else
		  RGBmuroFC1 when (muroFc1='1') else
		  RGBmurosCurvosC1 when (muroFcurvoC1='1') else
		  RGBmuroBc1 when (muroBc1='1') else	
		  RGBventanaULFc1 when (ventanaULFc1='1') else
		  RGBventanaURFc1 when (ventanaURFc1='1') else	
		  RGBventanaDLFc1 when (ventanaDLFc1='1') else	
		  RGBventanaDRFc1 when (ventanaDRFc1='1') else
		  RGBmurosLateralesC1 when (muroRcasaC1='1' or muroLcasaC1='1') else	
		  RGBmurosLateralesTechoC1 when (muroRtechoCasaC1='1' or muroLtechoCasaC1='1') else	
		  RGBtechitosC1 when (techoDC1='1' or techoUC1='1') else
		  RGBbalconesC1 when (balconUC1='1' or balconDC1='1') else
		  RGBazoteaC1 when (azoteaC1='1') else
		  RGBpuertaCasaC1 when (puertaCasaC1='1') else
		  RGBmarcoVentanasYpuertaC1 when (marcoVentanasYpuertaC1='1') else
		  RGBfachadaCasa when (fachadaCasaC1='1') else
		  RGBescalonesC1 when (anyEscalonC1='1')else
		  RGBfachadaEscalonesC1 when (fachadaCasaEscalonesC1='1') else
		  RGBpastoDentroC1 when (pastoDentroC1='1') else
		  RGBcieloC1 when (cieloC1='1') else
		  "100010000110" when (onFrameC1='1') else
		  "100010000110";
		  		  				  

RGBc2<= RGBcalleC2 			when (calleC2='1') else 
		  RGBbanquetaC2 		when (banquetaC2='1') else
		  RGBmuroBC1 			when (murosVc2='1' or murosHc2='1') else
		  RGBazoteaC2 			when (azoteaC2='1') else
		  RGBolasOFF			when (ola1='1' or ola2='1' or ola3='1')else
		  RGBolasON				when (ola4='1' or ola5='1' or ola6='1')else
	     RGBalbercaC2 		when (albercaC2='1') else
  		  RGBporton			   when (puertaFrenteC2='1' or portonC2='1') else
	     RGBmarcoAlbercaC2  when (marcoAlbercaC2='1') else
	     RGBpastoFueraC2    when (pastoFueraC2='1') else
	     RGBpastoDentroC2   when (pastoDentroC2='1') else
	     RGBfaroBLc2        when (faroBIc2='1') else
	     RGBfaroBRc2		   when (faroBDc2='1') else
	     RGBfaroFLc2        when (faroFIc2='1') else
	     RGBfaroFRc2  	   when (faroFDc2='1') else
		  "100010000110"     when (onFrameC2='1') else
		  "100010000110";
		  

RGBc3<= RGBventanaDRBc3 when (ventanaDRBc3='1') else 
		  RGBventanaDRFc3 when (ventanaDRFc3='1') else 
		  RGBventanaURBc3 when (ventanaURBc3='1') else 
		  RGBventanaURFc3 when (ventanaURFc3='1') else
   	  RGBpastoFueraC3 when (pastoFueraC3='1') else	
		  RGBbanquetaC3   when (banquetaC3='1') else
		  RGBmuroBC1	   when (murosVc3='1') else
		  RGBfaroFRc3     when (faroFRc3='1') else
		  RGBfaroBRc3     when (faroBRc3='1') else
		  RGBanyPoste     when (posteFRc3='1' or posteBRc3='1') else
		  RGBescalonesC3  when (anyEscalonC3='1' ) else
		  RGBfachadaCasa  when (muroRcasaC3='1') else
		  RGBmuroFc1      when (muroHc3='1') else
		  RGBcieloC3 		when (cieloC3='1') else
		  "100010000110"  when (onFrameC3='1') else
    	  "100010000110";
		  
RGBlb<= RGBhrH  			when (onHrH='1') else
		  RGBhrL  			when (onHrL='1') else
		  RGBminH 			when (onMinH='1') else
		  RGBminL 			when (onMinL='1') else
		  RGB2p   			when (on2p='1') else
		  RGBonO  			when (onON_o='1') else
		  RGBonN  			when (onON_n='1') else
		  RGBoffO  			when (onOFF_o='1') else
		  RGBoffF1 			when (onOFF_f1='1') else
		  RGBoffF2 			when (onOFF_f2='1') else
		  RGBinterruptor 	when (interruptorLB='1')else
		  RGBcelular 		when (celAntenaLB='1' or celCarcazaLB='1') else
		  RGBcelPantalla 	when (celPantallaLB='1')else
		  RGBcelTeclado 	when (celTecladoLB='1')else
		  RGBlockCentro 	when (lockCentroLB='1') else
		  RGBlockCandado 	when (lockCandadoLB='1') else
		  RGBlockArco 		when (lockRVarcoLB='1' or lockHarcoLB='1' or lockLV1arcoLB='1' or lockLV2arcoLB='1') else
		  "111111111111" 	when (onFrameLock='1' or onFrameCel='1' or onFrameInterruptor='1') else	
		  "000000000000";


--=======================================================================


--GENERA Salida final de RGB=============================================

Red<= RGBc1(11 downto 8) when (onCap1 = '1' and onCapsFrame = '0') else
		RGBc2(11 downto 8) when (onCap2 = '1' and onCapsFrame = '0') else
		RGBc3(11 downto 8) when (onCap3 = '1' and onCapsFrame = '0') else
		RGBlb(11 downto 8) when (onLeftBar = '1' and onCapsFrame = '0') else
		"1111" when (onCapsFrame = '1') else
		"0000";
		
Green<= RGBc1(7 downto 4) when (onCap1 = '1' and onCapsFrame = '0') else 
		  RGBc2(7 downto 4) when (onCap2 = '1' and onCapsFrame = '0') else
		  RGBc3(7 downto 4) when (onCap3 = '1' and onCapsFrame = '0') else
		  RGBlb(7 downto 4) when (onLeftBar = '1' and onCapsFrame = '0') else
		  "1111" when (onCapsFrame = '1') else
		  "0000";
		
Blue<= RGBc1(3 downto 0) when (onCap1 = '1' and onCapsFrame = '0') else
		 RGBc2(3 downto 0) when (onCap2 = '1' and onCapsFrame = '0') else
		 RGBc3(3 downto 0) when (onCap3 = '1' and onCapsFrame = '0') else
		 RGBlb(3 downto 0) when (onLeftBar = '1' and onCapsFrame = '0') else
		 "1111" when (onCapsFrame = '1') else
		 "0000";
		 
--=======================================================================

end Behavioral;

