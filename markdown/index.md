---
title: 'NutriSense: Automated Hydroponics Dosing System'
author: '**Kushagra Tiwari and Shengmin Liu** (website template by Ryan Tsang)'
date: '*EEC172 WQ24*'

subtitle: '<blockquote><b>EEC172 Final Project Webpage Example</b><br/>
Note to current students: this is an <i>example</i> webpage and
may not fulfill all stated requirements of the current quarter''s 
assignment.<br/>The website source is hosted 
<a href="https://github.com/ucd-eec172/project-website-example">on github</a>.
</blockquote>'

toc-title: 'Table of Contents'
abstract-title: '<h2>Description</h2>'
abstract: 'Hydroponics is a technique where plants are grown in a nutrient-rich
solution. This soil- free technique has been gaining traction recently
due to its ability to optimize resource utilization. However, since
plants are highly sensitive to changes in TDS, hydroponic setups require
continuous TDS monitoring and adjustment. NutriSense, our device, allows
hobbyists to achieve ideal hydroponics results on a small scale. It
continuously monitors TDS and temperature, allowing the user to remotely
read the status over AWS IoT cloud. The user can remotely enter upper
and lower thresholds for TDS, and the device will automatically add
nutrient solution or water to keep the TDS bounded by the thresholds.
The device can also be configured to send notifications over SNS when
the TDS value goes outside thresholds.
<br/><br/>
Our source code can be found 
<!-- replace this link -->
<a href="https://github.com/ucd-eec172/project-website-example">
  here (placeholder)</a>.

<div style="display:flex;flex-wrap:wrap;justify-content:space-evenly;padding-top:20px">
  <div style="display: inline-block; vertical-align: bottom;">
    <img src="./media/Image_001.jpg" style="width:auto;height:2in"/>
    <!-- <span class="caption"> </span> -->
  </div>
  <div style="display: inline-block; vertical-align: bottom;">
    <img src="./media/Image_002.jpg" style="width:auto;height:2in" />
    <!-- <span class="caption"> </span> -->
  </div>
</div>

<h2>Video Demo</h2>
<div style="text-align:center;margin:auto;max-width:560px">
  <div style="padding-bottom:56.25%;position:relative;height:0;">
    <iframe style="left:0;top:0;width:100%;height:100%;position:absolute;" width="560" height="315" src="https://www.youtube.com/embed/wSRtnAEZhmc?si=3vQXNj4h0WkW-F-q" title="YouTube video player" frameborder="0" allow="accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
  </div>
</div>
'
---

<!-- EDIT METADATA ABOVE FOR CONTENTS TO APPEAR ABOVE THE TABLE OF CONTENTS -->
<!-- ALL CONTENT THAT FOLLWOWS WILL APPEAR IN AND AFTER THE TABLE OF CONTENTS -->

# Market Survey

There are two types of similar product on the market. The first one is
products from AeroGarden. Their products allow users to grow plants in
nutrient solutions in a limited amount of usually 5 to 10. Compared with
this product, our product provides an automated system for nutrient
control that ensures the plant always has the correct amount of
nutrients needed to avoid excess or insufficient nutrients. The other
product is an expensive commercial system for horticulture aiming for a
large scale of growth. Compared with this one, our product has the
advantage of being cheap and small-scale which is more suitable for
individual hobbyists to explore hydroponics.

<div style="display:flex;flex-wrap:wrap;justify-content:space-evenly;">
  <div style='display: inline-block; vertical-align: top;'>
    <img src="./media/Image_003.jpg" style="width:auto;height:200"/>
    <span class="caption">
      <a href="https://aerogarden.com/gardens/harvest-family/Harvest-2.0.html">AeroGarden Harvest 2.0</a>
      <ul style="text-align:left;">
      <li>Inexpensive ($90)</li>
      <li>Not Automated</li>
      <li>Small Scale</li>
      <li>No remote monitoring</li>
    </ul>
    </span>
  </div>
  <div style='display: inline-block; vertical-align: top;'>
    <img src="./media/Image_004.jpg" style="width:auto;height:200" />
    <span class="caption">
      <a href="https://www.hydroexperts.com.au/Autogrow-MultiGrow-Controller-All-In-One-Controller-8-Growing-Zones">Autogrow Multigrow</a>
      <ul style="text-align:left;">
      <li>Expensive ($4500)</li>
      <li>Fully Automated</li>
      <li>Huge Scale</li>
      <li>Cloud monitoring</li>
    </ul>
    </span>
  </div>
</div>

# Design

## System Architecture

<div style="display:flex;flex-wrap:wrap;justify-content:space-evenly;">
  <div style="display:inline-block;vertical-align:top;flex:1 0 400px;">
    As shown in the system flowchart, we use one of the CC3200 boards for
    the closed feedback loop for maintaining concentration in the
    environment. The board will read values with I2C protocol through an ADC
    which reads values from the thermistor and the TDS meter sensor. The
    board will also periodically read user-defined thresholds from the AWS
    cloud using RESTful APIs. When the sensory values read outside of the
    user-defined thresholds, the board will activate the motor control
    function to pump either water or nutrient solution to bring the
    concentration back within the thresholds. Meanwhile, another CC3200
    board is frequently reading from the AWS cloud to present the current
    TDS reading and user-defined threshold to the user on an OLED through
    SPI protocols. To adjust the thresholds, the user can either do it
    remotely or locally by using a TV remote to type the number into the IR
    receiver. The adjustments will be updated to the AWS and if the user
    updates remotely, the local CC3200 board will update the values in the
    next synchronization.
  </div>
  <div style="display:inline-block;vertical-align:top;flex:0 0 400px;">
    <div class="fig">
      <img src="./media/Image_005.jpg" style="width:90%;height:auto;" />
      <span class="caption">System Flowchart</span>
    </div>
  </div>
</div>

## Functional Specification

<div style="display:flex;flex-wrap:wrap;justify-content:space-evenly;">
  <div style="display:inline-block;vertical-align:top;flex:1 0 300px;">
    Our system works based on the following state diagram. The device will
    periodically monitor the temperature and the electrical conductivity
    (EC) of the solution and convert the values into a TDS value using a
    calibration curve. At the same time, the device will check for threshold
    inputs, both over the AWS shadow and via manual input on the IR
    receiver. It will compare the TDS with the lower and upper thresholds
    set by the user. If the value is within the thresholds, it will stay in
    the rest state. If the TDS is higher than the upper thresholds, it will
    go to the water state and activate the water pump until the PPM is lower
    than the upper thresholds and go back to the rest state. If the PPM is
    lower than the lower thresholds, it will go to the nutrient state and
    activate the nutrient pump until the PPM is higher than the lower
    thresholds and go back to the rest state. In each state, the device will
    periodically post the TDS.
  </div>
  <div style="display:inline-block;vertical-align:top;flex:0 0 500px">
    <div class="fig">
      <img src="./media/Image_006.jpg" style="width:90%;height:auto;" />
      <span class="caption">State Diagram</span>
    </div>
  </div>
</div>

# Implementation

### CC3200-LAUNCHXL Evaluation Board

All control and logic was handled by two CC3200 microcontroller units,
one each for the Master and Slave device. On the master device, it was
responsible for decoding IR inputs from the remote to allow the user to
input thresholds to be sent over AWS. The board’s SPI functionality,
using the TI SPI library, was used to interface with the OLED display.
The MCU is WiFi enabled, allowing a remote connection between the two
boards.

On the slave device, the microcontroller was responsible for the same
functionalities as above, in addition to the TDS reading and control.
This includes interfacing with the ADC over the I2C bus, reading 
thresholds over HTTP from the AWS device shadow, writing the reported 
TDS to the device shadow, and activating the two pumps using the 
BJT control circuit.

## Functional Blocks: Master

### AWS IoT Core

<div style="display:flex;flex-wrap:wrap;justify-content:space-between;">
  <div style='display: inline-block; vertical-align: top;flex:1 0 200px'>
    The AWS IoT core allows our devices to communicate with each other
    asynchronously. The master device can update the desired thresholds, and
    the slave device will read them and synchronize them to the reported
    state. The slave device will also post the TDS and temperature readings
    periodically.
  </div>
  <div style='display: inline-block; vertical-align: top;flex:0 0 400px'>
    <div class="fig">
      <img src="./media/Image_007.jpg" style="width:auto;height:2.5in" />
      <span class="caption">Device Shadow JSON</span>
    </div>
  </div>
</div>

### OLED Display

<div style="display:flex;flex-wrap:wrap;justify-content:space-between;">
  <div style='display: inline-block; vertical-align: top;flex:1 0 400px'>
    On both Master and Slave devices, the user can view the current TDS and
    temperature of the plant solution on an OLED display. The user can also
    use the display to view and edit the TDS thresholds. The CC3200 uses the
    SPI bus to communicate with the display module.
  </div>
  <div style='display: inline-block; vertical-align: top;flex:0 0 400px'>
    <div class="fig">
      <img src="./media/Image_008.jpg" style="width:auto;height:2in" />
      <span class="caption">OLED Wiring Diagram</span>
    </div>
  </div>
</div>

### IR Receiver

<div style="display:flex;flex-wrap:wrap;justify-content:space-between;">
  <div style='display: inline-block; vertical-align: top;flex:1 0 400px'>
    On both the Master and Slave devices, a user can input the TDS
    thresholds using a TV remote. These TV remotes use the NEC code format
    with a carrier frequency of 38KHz. The Vishay IR receiver is connected
    to Pin 62 of the CC3200, which is configured as a GPIO input pin. Each
    positive edge of the signal triggers an interrupt in the main program,
    storing the pulse distances into a buffer, and allowing us to decode the
    inputs (1-9, delete and enter). The IR receiver is connected to VCC
    through a resistor and a capacitor to filter any ripples.
  </div>
  <div style='display: inline-block; vertical-align: top;flex:0 0 400px'>
    <div class="fig">
      <img src="./media/Image_009.jpg" style="width:auto;height:2in" />
      <span class="caption">IR Receiver Wiring Diagram</span>
    </div>
  </div>
</div>

## Functional Blocks: Slave

The slave device contains all the functional blocks from the master
device, plus the following:

### Analog-To-Digital Converter (ADC) Board

<div style="display:flex;flex-wrap:wrap;justify-content:space-between;">
  <div style='display: inline-block; vertical-align: top;flex:1 0 400px'>
    The outputs from the thermistor and TDS sensor board are
    in the form of analog voltages, which need to be converted to digital
    values to be usable in our program. We chose the AD1015 breakout board
    from Adafruit, which sports 4-channels and 12 bits of precision. We
    ended up using only 2 channels, so there is a potential for even more
    cost savings. The ADC board supports I2C communication, which we can use
    to request and read the two channel voltages. 
    The <a href="https://cdn-shop.adafruit.com/datasheets/ads1015.pdf">
    product datasheet</a> contains the necessary configuration values
    and register addresses for operation.
  </div>
  <div style='display: inline-block; vertical-align: top;flex:1 0 400px'>
    <div class="fig">
      <img src="./media/Image_010.jpg" style="width:auto;height:2in" />
      <span class="caption">ADC Wiring Diagram</span>
    </div>
  </div>
</div>

### Thermistor

<div style="display:flex;flex-wrap:wrap;justify-content:space-between;">
  <div style='display: inline-block; vertical-align: top;flex:1 0 300px;'>
    Conductivity-based TDS measurements are sensitive to temperature. To
    allow accurate TDS measurements in a variety of climates and seasons,
    temperature compensation calculations must be performed. To measure the
    temperature, we use an NTC thermistor connected in a voltage divider
    with a 10k resistor. The voltage across the resistor is read by the ADC
    and converted to temperature using the equation provided by the
    thermistor datasheet.
  </div>
  <div style='display: inline-block; vertical-align: top;flex:1 0 400px'>
    <div class="fig">
      <img src="./media/Image_011.jpg" style="width:auto;height:2in" />
      <span class="caption">Thermistor Circuit Diagram</span>
    </div>
  </div>
</div>

### TDS Sensor Board

<div style="display:flex;flex-wrap:wrap;justify-content:space-between;">
  <div style='display: inline-block; vertical-align: top;flex:1 0 500px'>
    In our first attempt to measure TDS, we used a simple two-probe analog
    setup with a voltage divider. We soon found out that this was a naïve
    approach (see Challenges). Consequently, we acquired a specialty TDS
    sensing board from CQRobot, which generates a sinusoidal pulse and
    measures the voltage drop to give a highly precise voltage to the ADC.
    The MCU can then convert this voltage to a TDS value using the equation
    provided by the device datasheet. We calibrated the TDS readings using a
    standalone TDS sensor pen. After calibration and setting up the curves
    for temperature compensation, we were able to achieve TDS readings
    accurate to within 5% of the TDS sensor pen.
  </div>
  <div style='display: inline-block; vertical-align: top;flex:1 0 600px'>
    <div class="fig">
      <img src="./media/Image_012.jpg" style="width:auto;height:2in;padding-top:30px" />
      <span class="caption">TDS Sensor Wiring Diagram</span>
    </div>
  </div>
</div>

### Pumps and Control Circuit

<div style="display:flex;flex-wrap:wrap;justify-content:space-between;">
  <div style='display: inline-block; vertical-align: top;flex:1 0 500px'>
    The CC3200 is unable to provide sufficient power to drive the pumps,
    which need 100mA of current each. Therefore, we used an external power
    source in the form of 2 AA batteries for each pump motor. To allow the
    CC3200 to turn on/off the motors, we designed a simple amplifier using a
    Common Emitter topology. When the control pin is asserted HIGH, the BJT
    will allow current to flow from 3V to ground through the pump motor.
    Conversely, if the control signal is LOW, the BJT will not allow current
    to flow in the motor. For each motor, there is a reverse-biased diode
    connected across it. This protects our circuit from current generated by
    the motor if it is spun from external force or inertia.
  </div>
  <div style='display: inline-block; vertical-align: top;flex:1 0 600px'>
    <div class="fig">
      <img src="./media/Image_013.jpg" style="width:auto;height:2in;padding-top:30px" />
      <span class="caption">Pump Circuit Diagrams</span>
    </div>
  </div>
</div>

# Challenges

The most significant challenge we faced while developing this prototype
was of inaccurate and inconsistent Electrical Conductivity (EC)
measurements. This occurred due to two reasons: probe channel
polarization and current limitations of GPIO pins.

## Probe Channel Polarization

Our first design for the probe was simply two copper rods, which would
add as electrodes. This probe would be connected in series with a
1000-ohm resistor to act as a voltage divider. We would simply connect
the probe to VCC and measure the voltage divider through the ADC,
allowing us to calculate the EC. However, when we used the probe for a
few minutes, we realized that the EC value would continue to rise. This
is because the DC current causes an ionized channel to build up between
the two electrodes in the water. This cause inconsistent EC readings as
time goes on.

## Current Limitation of GPIO Pins

Our next idea was to try using the GPIO pins to power the probe, since
we can turn it off when not needed, preventing excessive polarization.
However, the GPIO pins are current limited, and any control circuit with
a transistor would introduce extra voltage drops. Therefore, the simple
two-probe implementation was not feasible.

## Solution to Challenges

We realized that using DC current to measure EC was not feasible.
Therefore, we purchased a standalone EC measurement board from CQRobot.
This inexpensive solution (\$8) used a low-voltage, low-current AC
signal to prevent polarization. The board would convert the AC voltage
drop across the solution to a DC analog voltage, which would then be
read by our ADC. After calibrating the setup using a commercial TDS pen,
the results were accurate within 3%, and would not drift by more than
0.5% over time.

# Future Work

Given more time, we had the idea of developing a web app to allow users
to control the device from their cell phone. Another idea we wanted to
implement in the future is adding a grow light and pH controller to
maintain a more suitable and stable environment for different plants to
grow.


# Finalized BOM

<!-- you can convert google sheet cells to html for free using a converter
  like https://tabletomarkdown.com/convert-spreadsheet-to-html/ -->

<table style="border-collapse:collapse;">
<thead>
  <tr>
    <th><p>No.</p></th>
    <th><p>PART NAME</p></th>
    <th><p>DESCRIPTION</p></th>
    <th><p>Qty</p></th>
    <th><p>SUPPLIER / MANUFACTURER</p></th>
    <th><p>UNIT COST</p></th>
    <th><p>TOTAL PART COST</p></th>
    <th><p>Purpose</p></th>
  </tr>
</thead>
<tbody>
  <tr>
    <td><p>1</p></td>
    <td><p>CC3200-LAUNCHXL</p></td>
    <td><p>MCU Evaluation Board</p></td>
    <td><p>2</p></td>
    <td><p>Provided by EEC172 Course</p></td>
    <td><p>$66.00</p></td>
    <td><p>$132.00</p></td>
    <td><p>Control Remote and Local Devices</p></td>
  </tr>
  <tr>
    <td><p>2</p></td>
    <td><p>Adafruit 1431 OLED</p></td>
    <td><p>128x128 RGB OLED Display. SPI protocol</p></td>
    <td><p>2</p></td>
    <td><p>Provided by EEC172 Course</p></td>
    <td><p>$39.95</p></td>
    <td><p>$79.90</p></td>
    <td><p>Display PPM, Temperature, Thresholds, Inputs</p></td>
  </tr>
  <tr>
    <td><p>3</p></td>
    <td><p>Adafruit 4547 3VDC Pump</p></td>
    <td><p>Submersible pump. 3V 100mA DC</p></td>
    <td><p>2</p></td>
    <td><p>Adafruit</p></td>
    <td><p>$2.95</p></td>
    <td><p>$5.90</p></td>
    <td><p>For dispensing water and nutrient solution</p></td>
  </tr>
  <tr>
    <td><p>4</p></td>
    <td><p>Adafruit 4545 6mm Tube</p></td>
    <td><p>6mm Silicone Tube: 1 meter length</p></td>
    <td><p>1</p></td>
    <td><p>Adafruit</p></td>
    <td><p>$1.50</p></td>
    <td><p>$1.50</p></td>
    <td><p>For dispensing water and nutrient solution</p></td>
  </tr>
  <tr>
    <td><p>5</p></td>
    <td><p>NTC Thermistor 10k</p></td>
    <td><p>10k ohm nominal resistance, 100cm lead</p></td>
    <td><p>1</p></td>
    <td><p>(Already had one, available on Aliexpress)</p></td>
    <td><p>$0.92</p></td>
    <td><p>$0.92</p></td>
    <td><p>For temperature compensation</p></td>
  </tr>
  <tr>
    <td><p>6</p></td>
    <td><p>Adafruit AD1015 12-bit ADC</p></td>
    <td><p>12-bit resolution, 4 channels, I2C</p></td>
    <td><p>1</p></td>
    <td><p>Adafruit</p></td>
    <td><p>$9.95</p></td>
    <td><p>$9.95</p></td>
    <td><p>To convert Thermistor and TDS sensor reading to digital</p></td>
  </tr>
  <tr>
    <td><p>7</p></td>
    <td><p>PN2222A Transistor</p></td>
    <td><p>NPN BJT (40V, 1000mA)</p></td>
    <td><p>2</p></td>
    <td><p>Digikey (onSemi)</p></td>
    <td><p>$0.40</p></td>
    <td><p>$0.80</p></td>
    <td><p>For digital motor control</p></td>
  </tr>
  <tr>
    <td><p>8</p></td>
    <td><p>1N4001 Rectifier Diode</p></td>
    <td><p>Diffused junction: 50V 1000mA</p></td>
    <td><p>2</p></td>
    <td><p>Digikey (Good-Ark Semi)</p></td>
    <td><p>$0.16</p></td>
    <td><p>$0.32</p></td>
    <td><p>Reverse Current Protection</p></td>
  </tr>
  <tr>
    <td><p>9</p></td>
    <td><p>10k ohm resistor</p></td>
    <td><p>10k ohm , 1% tolerance, 0.25W</p></td>
    <td><p>1</p></td>
    <td><p>Digikey (Stackpole Electronics)</p></td>
    <td><p>$0.10</p></td>
    <td><p>$0.10</p></td>
    <td><p>Voltage divider for Thermistor</p></td>
  </tr>
  <tr>
    <td><p>10</p></td>
    <td><p>Vishay TSOP31130 IR RCVR</p></td>
    <td><p>30kHz carrier frequency</p></td>
    <td><p>2</p></td>
    <td><p>Provided by EEC172 Course</p></td>
    <td><p>$1.41</p></td>
    <td><p>$2.82</p></td>
    <td><p>Decode user inputs</p></td>
  </tr>
  <tr>
    <td><p>11</p></td>
    <td><p>330 ohm resistor</p></td>
    <td><p>330 ohm resistor, &lt;5% tolerance, 3W</p></td>
    <td><p>2</p></td>
    <td><p>Provided by EEC172 Course</p></td>
    <td><p>$0.59</p></td>
    <td><p>$1.18</p></td>
    <td><p>Current Limit for IR Receiv er</p></td>
  </tr>
  <tr>
    <td><p>12</p></td>
    <td><p>ATT-RC1534801 Remote</p></td>
    <td><p>General-purpose TV remote. IR NTC protocol</p></td>
    <td><p>1</p></td>
    <td><p>Provided by EEC172 Course</p></td>
    <td><p>$9.99</p></td>
    <td><p>$9.99</p></td>
    <td><p>Allow user inputs</p></td>
  </tr>
  <tr>
    <td><p>13</p></td>
    <td><p>CQRSENTDS01 TDS Sensor</p></td>
    <td><p>Analog reading 0-2.3V. 0-1000ppm range</p></td>
    <td><p>1</p></td>
    <td><p>CQRobot</p></td>
    <td><p>$7.99</p></td>
    <td><p>$7.99</p></td>
    <td><p>Measure TDS of plant solution</p></td>
  </tr>
  <tr>
    <td><p>14</p></td>
    <td><p>10uF Capacitor</p></td>
    <td><p>Electrolytic Cap 100V</p></td>
    <td><p>2</p></td>
    <td><p>Provided by EEC172 Course</p></td>
    <td><p>$0.18</p></td>
    <td><p>$0.36</p></td>
    <td><p>DC Filtering for IR Receiv er</p></td>
  </tr>
  <tr>
    <td><p>15</p></td>
    <td><p><u>AA Battery (4ct</u>)</p></td>
    <td><p>1.5 Volt, Non-rechargable</p></td>
    <td><p>1</p></td>
    <td><p>Already had, but</p>
      <p>available on Amazon</p></td>
    <td><p>$3.65</p></td>
    <td><p>$3.65</p></td>
    <td><p>Provide Power to Motors</p></td>
  </tr>
  <tr>
    <td><p>16</p></td>
    <td><p>Battery Holder</p></td>
    <td><p>2xAA (3 Volts Total)</p></td>
    <td><p>2</p></td>
    <td><p>Amazon</p></td>
    <td><p>$2.50</p></td>
    <td><p>$4.99</p></td>
    <td><p>Provide Power to Motors</p></td>
  </tr>
  <tr>
    <td colspan="3">
      <p>TOTAL PARTS</p></td>
    <td><p>25</p></td>
    <td colspan="2">
      <p>TOTAL</p></td>
    <td><p>$262.37</p></td>
    <td></td>
  </tr>
  <tr>
    <td colspan="3">
      <p>TOTAL PARTS (Excluding Provided)</p></td>
    <td><p>14</p></td>
    <td colspan="2">
      <p>TOTAL (Exluding Provided)</p></td>
    <td><p>$36.12</p></td>
    <td></td>
  </tr>
</tbody>
</table>