// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
 
contract Meteo_Station{

	struct data1 {
		string Timestamp;
		string time;
		string TempIn;
		string TempOut;
		string HumIn;
		string HumOut;
		string BarTrend;
		string WindSpeed;
		string WindDir;
		string RainDay;
	}

	struct data2 {
		string SolarRad;
		string UV;
		string RainRate;
		string SunRise;
		string SunSet;
		string Barometer;
		string EtDay;
	}

  	data1[] public weather_station_data1;
	data2[] public weather_station_data2;
		
	function add_Data1(string memory _Timestamp, string memory _time, string memory _TempIn, string memory _TempOut, string memory _HumIn, string memory _HumOut, string memory _BarTrend, string memory _WindSpeed, string memory _WindDir, string memory _RainDay) public {
		weather_station_data1.push(data1({Timestamp: _Timestamp, time: _time, TempIn: _TempIn, TempOut: _TempOut, HumIn: _HumIn, HumOut: _HumOut, BarTrend: _BarTrend, WindSpeed: _WindSpeed, WindDir: _WindDir, RainDay: _RainDay}));  
	}

	function add_Data2(string memory _SolarRad, string memory _UV, string memory _RainRate, string memory _SunRise, string memory _SunSet, string memory _Barometer, string memory _EtDay) public {
		weather_station_data2.push(data2({SolarRad: _SolarRad, UV: _UV, RainRate: _RainRate, SunRise: _SunRise, SunSet: _SunSet, Barometer: _Barometer, EtDay: _EtDay})); 
	}
	
	function Call_Data() public view returns (data1[] memory, data2[] memory) {
		return (weather_station_data1, weather_station_data2);
	} 

}