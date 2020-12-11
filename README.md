# mt4demo
## about
a demo to perform algotrading with predefined parameters.
## usage
- this code is for both backtest / trading
- make sure the file are placed into local mql4 folders respectedly.
### backtest
- simply compile & select the strategy located in Expert Advisors, then start backtest.
### live trading / monitoring
- compile the strategy
- enable / disable "Auto Trading" 
- locate the desired Expert Advisor in Navigator panel
- pull it to the chart in desired product
- check "Allow DLL imports" to enable telegram feature
- done.

## advanced details

### constants
These should be defined before usage.
```
#define STRATEGY_NAME         "EXPERT-DEMO"
#define TimerConst            3000
#define tradingQty            1
```
- the name shall be shown in messaging
- tradingQty is default to 1 for respected product on the chart.

### inputs
these are to be altered during the calibration / backtest.
#### stoploss / stopgain (takeprofit)
```
double Stoplosspt = 0; // stoploss point
double Stoplosspc = 0; // stoploss percentage
double Stopgainpt = 0; // stopgain point
double Stopgainpc = 0; // stopgain percentage
```

- stoploss / stopgain are defined as point & percentage. 
- 0 to disable.
- if both point & percentage are enabled, point will be used.

#### hysteresis
```
#define CONFIG_IGNORE_HYSTERESIS        true
#define PreOrderHysteresispc            0.05
```
- this avoids execessive trading as conditions are touching the threshold (i.e. turning on/off frequenctly)
- e.g. with it sets to 0.1%, once Rising trend exists at 10000pt, 
- the bot shall confirm a Rising Trend only if it continues to rise above 10010.
#### close at opposite trade?
```
#define CONFIG_CLOSE_AT_OPPOSITE_TREND  false
```
this selects desired close condition with respect to the trend:
- true: CLOSE only if opposite trend 
- false: CLOSE with change of trend
#### hour mode
trading can be restricted with restricted hour range with this mode.
```
#define CONFIG_ALGO_HOURMODE           ALGO_HOURMODE_CLOSE_ONLY
#define CONFIG_ALGO_SHOUR              23
#define CONFIG_ALGO_EHOUR              8
```
options for CONFIG_ALGO_HOURMODE
- ALGO_HOURMODE_OFF:        disable HOURMODE function
- ALGO_HOURMODE_ON:         restrict trading within restricted hour range
- ALGO_HOURMODE_CLOSE_ONLY: only OPEN ORDER is restricted within restricted hour range

restricted hour range variable:
- CONFIG_ALGO_SHOUR: start of restricted hour range
- CONFIG_ALGO_EHOUR: end of restricted hour range
