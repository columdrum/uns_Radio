uns_radio_owner=_this select 0;
createdialog "uns_radio_MainDiag";

/*
$[1.03,[[0,0,1,1],0.03125,0.05],[1000,"",[1,"ON",["0.681548 * safezoneW + safezoneX","0.292462 * safezoneH + safezoneY","0.0214844 * safezoneW","0.0137446 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1001,"",[1,"OFF",["0.679762 * safezoneW + safezoneX","0.332446 * safezoneH + safezoneY","0.0286458 * safezoneW","0.0274893 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1600,"",[1,"power",["0.62619 * safezoneW + safezoneX","0.295318 * safezoneH + safezoneY","0.0458333 * safezoneW","0.0549786 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1601,"",[1,"Call Air Suppor /Arty",["0.507161 * safezoneW + safezoneX","0.458766 * safezoneH + safezoneY","0.117857 * safezoneW","0.0454585 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1602,"",[1,"Call air extraction",["0.545238 * safezoneW + safezoneX","0.578065 * safezoneH + safezoneY","0.100595 * safezoneW","0.0416505 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]]]

$[1.03,[[0,0,1,1],0.03125,0.05],[1200,"",[1,"\uns_radio\GUI\radio.paa",["0.287561 * safezoneW + safezoneX","0.284951 * safezoneH + safezoneY","0.425121 * safezoneW","0.46005 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1201,"",[1,"\uns_radio\GUI\powerOFF.paa)",["0.625698 * safezoneW + safezoneX","0.365332 * safezoneH + safezoneY","0.0458201 * safezoneW","0.0550047 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1202,"",[1,"\uns_radio\GUI\powerON.paa",["0.63158 * safezoneW + safezoneX","0.366377 * safezoneH + safezoneY","0.0458201 * safezoneW","0.0550047 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1203,"",[1,"\uns_radio\GUI\selector1.paa",["0.605119 * safezoneW + safezoneX","0.593954 * safezoneH + safezoneY","0.0406746 * safezoneW","0.0811029 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1204,"",[1,"\uns_radio\GUI\selector2.paa",["0.608057 * safezoneW + safezoneX","0.650325 * safezoneH + safezoneY","0.036264 * safezoneW","0.0831907 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1205,"",[1,"\uns_radio\GUI\selector4.paa",["0.369156 * safezoneW + safezoneX","0.450936 * safezoneH + safezoneY","0.0590516 * safezoneW","0.0800589 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1206,"",[1,"\uns_radio\GUI\selector3.paa",["0.364746 * safezoneW + safezoneX","0.447803 * safezoneH + safezoneY","0.0597866 * safezoneW","0.080059 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]]]

$[1.03,[[0,0,1,1],0.03125,0.05],[1200,"",[1,"\uns_radio\GUI\radio.paa",["0.287561 * safezoneW + safezoneX","0.284951 * safezoneH + safezoneY","0.425121 * safezoneW","0.46005 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1201,"",[1,"\uns_radio\GUI\powerOFF.paa)",["0.625698 * safezoneW + safezoneX","0.365332 * safezoneH + safezoneY","0.0458201 * safezoneW","0.0550047 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1202,"",[1,"\uns_radio\GUI\powerON.paa",["0.63158 * safezoneW + safezoneX","0.366377 * safezoneH + safezoneY","0.0458201 * safezoneW","0.0550047 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1203,"",[1,"\uns_radio\GUI\selector1.paa",["0.605119 * safezoneW + safezoneX","0.593954 * safezoneH + safezoneY","0.0406746 * safezoneW","0.0811029 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1204,"",[1,"\uns_radio\GUI\selector2.paa",["0.608057 * safezoneW + safezoneX","0.650325 * safezoneH + safezoneY","0.036264 * safezoneW","0.0831907 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1205,"",[1,"\uns_radio\GUI\selector4.paa",["0.369156 * safezoneW + safezoneX","0.450936 * safezoneH + safezoneY","0.0590516 * safezoneW","0.0800589 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1206,"",[1,"\uns_radio\GUI\selector3.paa",["0.364746 * safezoneW + safezoneX","0.447803 * safezoneH + safezoneY","0.0597866 * safezoneW","0.080059 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1600,"",[1,"",["0.613937 * safezoneW + safezoneX","0.614832 * safezoneH + safezoneY","0.0237676 * safezoneW","0.0998937 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"Power"],[]],[1601,"",[1,"evasup",["0.367686 * safezoneW + safezoneX","0.45198 * safezoneH + safezoneY","0.0575813 * safezoneW","0.0758833 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"selector"],[]],[1602,"",[1,"usar",["0.352249 * safezoneW + safezoneX","0.643018 * safezoneH + safezoneY","0.0796338 * safezoneW","0.0278625 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"use"],[]],[1603,"",[1,"cerrar",["0.464716 * safezoneW + safezoneX","0.640931 * safezoneH + safezoneY","0.0590515 * safezoneW","0.0278625 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"close"],[]],[1604,"",[1,"support",["0.422816 * safezoneW + safezoneX","0.419618 * safezoneH + safezoneY","0.170784 * safezoneW","0.0299504 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"Support channel"],[]],[1605,"",[1,"evac",["0.434578 * safezoneW + safezoneX","0.5 * safezoneH + safezoneY","0.110507 * safezoneW","0.0309943 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"Air extract"],[]]]



$[1.03,[[0,0,1,1],0.03125,0.05],[2100,"",[1,"",["0.414923 * safezoneW + safezoneX","0.364253 * safezoneH + safezoneY","0.112713 * safezoneW","0.0247307 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1000,"",[1,"Smoke",["0.350778 * safezoneW + safezoneX","0.366377 * safezoneH + safezoneY","0.0428798 * safezoneW","0.020555 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1001,"",[1,"Extraction Type",["0.307409 * safezoneW + safezoneX","0.417529 * safezoneH + safezoneY","0.089925 * safezoneW","0.0309943 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[2101,"",[1,"",["0.4162 * safezoneW + safezoneX","0.418573 * safezoneH + safezoneY","0.111242 * safezoneW","0.0257747 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1002,"",[1,"Available helicopters",["0.28021 * safezoneW + safezoneX","0.47599 * safezoneH + safezoneY","0.110507 * safezoneW","0.021599 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[2102,"",[1,"",["0.415465 * safezoneW + safezoneX","0.472858 * safezoneH + safezoneY","0.109771 * safezoneW","0.0289065 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1600,"",[1,"Request",["0.326522 * safezoneW + safezoneX","0.555328 * safezoneH + safezoneY","0.053906 * safezoneW","0.0278625 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1601,"",[1,"cancel",["0.466186 * safezoneW + safezoneX","0.555328 * safezoneH + safezoneY","0.0605218 * safezoneW","0.0278625 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]],[1003,"",[1,"",["0.266979 * safezoneW + safezoneX","0.287039 * safezoneH + safezoneY","0.292072 * safezoneW","0.365052 * safezoneH"],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],""],[]]]
*/
