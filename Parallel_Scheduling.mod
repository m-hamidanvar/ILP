
set Nodes dimen 4;
set Messages dimen 4;

set node:=setof{(n,x,y,e)in Nodes}n;
set src:=setof{(n,x,y,e)in Nodes}n;
set dest:=setof{(n,x,y,e)in Nodes}n;
set msg:=setof{(m,s,ds,dln)in Messages}m;
/* A liner model is proposed*/
param time:=max{(m,s,ds,dln)in Messages}dln;
param d{n in node,n1 in node}:=min{(n,x,y,e) in Nodes,(n1,x1,y1,e1) in Nodes}sqrt(((x-x1)^2)+((y-y1)^2));
param C :=0.2;

var X{1..time,src,dest,msg},binary;
var Deliver >= 0;
var Energy >= 0;

/*transmission range constraint */
s.t. c1{t in 1..time,(i,x,y,e) in Nodes,j in dest,k in msg}:X[t,i,j,k]*d[i,j]<=sqrt(e);

/*constraints related to transmit and receive simultaneously*/
s.t. c2{t in 1..time,i in node}:sum{s in src,k in msg}X[t,s,i,k]+sum{j in dest,k in msg}X[t,i,j,k]<=1;

/*constraints related to sending and receiving more than one message by a node at a time */

s.t. c3{j in dest,t in 1..time}:sum{i in src,k in msg}X[t,i,j,k]<=1;
s.t. c4{i in src,t in 1..time}:sum{j in dest,k in msg}X[t,i,j,k]<=1;

/*constraints related to interfering transmissions according to protocol model*/
s.t. c5{t in 1..time,(i,x,y,e) in Nodes,s in src,j in dest:s!=i and i!=j and d[j,s]<d[i,j] }:sum{k in msg}X[t,i,j,k]+sum{d1 in dest,m in msg}X[t,s,d1,m]<=1;

/*determines energy source limitation for each node to transmit*/
s.t. c6{(i,x,y,e)in Nodes}:sum{t in 1..time,j in dest,k in msg}X[t,i,j,k]*C*(d[i,j]^2)<=e;

s.t. c7{t in 1..time,(k,s,ds,dln)in Messages:t>dln}:sum{i in src,j in dest}X[t,i,j,k]=0;

/*connectivity of the selected path*/
s.t. c8{(i,x,y,e)in Nodes,(k,sr,ds,dln)in Messages:i!=sr and i!=ds}:sum{t in 1..time,s in src:t<dln}X[t,s,i,k]-sum{t2 in 1..time,j in dest:t2<=dln}X[t2,i,j,k]=0;

/*a message should not enter to it's source node*/
s.t. c9{(i,x,y,e)in Nodes,(k,sr,ds,dln)in Messages:i==sr}:sum{t in 1..time,s in src}X[t,s,i,k]=0;

/*a message should not leave the destination node */
s.t. c10{(i,x,y,e)in Nodes,(k,sr,ds,dln)in Messages:i==ds}:sum{t2 in 1..time,j in dest}X[t2,i,j,k]=0;

/*ensures that each node either sends a message once only or not at all*/
s.t. c11{k in msg,i in src}:sum{t in 1..time,j in dest}X[t,i,j,k]<=1;

/*sending time of a message by the intermediate node is after the receiving time of that message */
s.t. c12{i in node,(k,sr,ds,dln)in Messages:(i!=sr and i!=ds)}:sum{t2 in 1..time,j in dest: t2<=dln}X[t2,i,j,k]*(t2-(dln*ceil(t2/dln)))-sum{t1 in 1..time,s in src:t1<=dln}X[t1,s,i,k]*(t1-(dln*ceil(t1/dln)))>=0;

/*s.t. c14{t in 1..time,i in src,j in dest,(k,sr,ds,dln)in Messages}:X[t,i,j,k]*d[j,ds]<=d[i,ds];*/

/*calculate delivered messages*/
s.t. c13:sum{(k,sr,ds,dln)in Messages,i in src,t in 1..time:t<=dln }X[t,i,ds,k]=Deliver;

/*calculate total energy consumption*/
s.t. c14:sum{t in 1..time,i in src,j in dest,k in msg}X[t,i,j,k]*(d[i,j]^2)=Energy;





minimize obj: Energy-800*Deliver;
solve;

display {t in 1..time,(k,sr,ds,dln)in Messages,i in src,j in dest:X[t,i,j,k]==1}X[t,i,j,k];

display Energy;
display Deliver;


data;
set Nodes:=

       /*(n1 , 5  ,5,25)
       (n2 , 5  ,8 ,25)
       (n3 , 7  ,7 ,25)
       (n4 , 9  ,9 ,25)
       (n5 , 8  ,11,25)
       (n6 , 12 ,9,25)
       (n7 , 14 ,7 ,25)
       (n8 , 15 ,9 ,25)
       (n9 , 16 ,11,25)
       (n10, 15 ,13,25)
/*(n1 , 8  ,15 ,100)
(n2 , 12  ,17 ,100)
(n3 , 11  ,6 ,100)
(n4 , 4  ,8 ,100)
(n5 , 11  ,18,100)
(n6 , 1 ,11 ,100)
(n7 , 3 ,16 ,100)
(n8 , 11 ,2 ,100)
(n9 , 19 ,15,100)
(n10 ,18 ,10,100) */

      /* (n1 , 6  ,10,25)
       (n2 , 2  ,10 ,25)
       (n3 , 16  ,17 ,25)
       (n4 , 15  ,15 ,25)
       (n5 , 8  ,6,25)
       (n6 , 4 ,18,25)
       (n7 , 11 ,19 ,25)
       (n8 , 12 ,0 ,25)
       (n9 , 12 ,1,25)
       (n10, 3 ,7,25)*/

      /* (n1 , 19  ,1,25)
       (n2 , 10  ,5 ,25)
       (n3 , 14  ,9 ,25)
       (n4 , 12  ,11 ,25)
       (n5 , 19  ,16,25)
       (n6 , 1 ,11,25)
       (n7 , 15 ,13 ,25)
       (n8 , 14 ,10 ,25)
       (n9 , 19 ,15,25)
       (n10, 1 ,12,25)*/

      /* (n1 , 9  ,3,25)
       (n2 , 6  ,1 ,25)
       (n3 , 10  ,18 ,25)
       (n4 , 5  ,19 ,25)
       (n5 , 10  ,13,25)
       (n6 , 13   ,9,25)
       (n7 , 5 ,2 ,25)
       (n8 , 13 ,17 ,25)
       (n9 , 16 ,8,25)
       (n10, 0 ,18,25)*/
/*(n1 , 5  ,5 ,100)
(n2 , 5  ,8 ,25)
(n3 , 7  ,7 ,25)
(n4 , 9  ,9 ,25)
(n5 , 8  ,11,25)
(n6 , 12 ,9 ,25)
(n7 , 14 ,7 ,25)
(n8 , 15 ,9 ,25)
(n9 , 16 ,11,25)
(n10 ,15 ,13,25)
/*(n11 ,5  ,14,25)
(n12 ,6  ,13,25)
(n13 ,6  ,12,25)
(n14 ,12 ,15,25)
(n15 ,10 ,13,25)
(n16 ,7  ,17,25)
(n17 ,10 ,17,25)
(n18 ,9  ,18,25)
(n19 ,10 ,20,25)
(n20,13  ,20,25)
(n20,13  ,20,10)
          /*  (n21,17  ,18,25)
            (n22,15  ,22,25)
            (n23,4   ,19,25)
            (n24,2   ,20,25)
            (n25,6   ,21,25)
            (n26,8   ,22,25)


            (n27,12  ,23,25)
            (n28,3   ,23,25)
            (n29,7   ,24,25)
            (n30,5   ,25,25)*/
            /*(n31,14  ,24,25)
            (n32,12  ,26,25)
            (n33,3   ,14,25)
            (n34,1   ,12,25)
            (n35,8   ,15,25)*/
/*===============================

      (n1 , 19  ,1,25)
       (n2 , 10  ,5 ,25)
       (n3 , 14  ,9 ,25)
       (n4 , 12  ,11 ,25)
       (n5 , 19  ,16,25)
       (n6 , 1 ,11,25)
       (n7 , 15 ,13 ,25)
       (n8 , 14 ,10 ,25)
       (n9 , 19 ,15,25)
       (n10, 1 ,12,25)
=============================*/

/*===1)
(n1 , 19  ,1,100)
       (n2 , 10  ,5 ,100)
       (n3 , 14  ,9 ,100)
       (n4 , 12  ,11 ,100)
       (n5 , 19  ,16,100)
       (n6 , 1 ,11,100)
       (n7 , 15 ,13 ,100)
       (n8 , 14 ,10 ,100)
       (n9 , 19 ,15,100)
       (n10, 1 ,12,100)

/*==================================*/
/*2)==================================
(n1 , 2  ,10,100)
(n2 , 16  ,17 ,100)
       (n3 , 15 , 15 ,100)
       (n4 , 8  ,6 ,100)
       (n5 , 4  ,18,100)
       (n6 , 11 ,19,100)
       (n7 , 15 ,13 ,100)
       (n8 , 14 ,10 ,100)
       (n9 , 19 ,15,100)
(n10, 1 ,12,100)
/*=======================================*/
/*3)======================
(n1 , 10  ,19,100)
(n2 , 15  ,1 ,100)
       (n3 , 12 , 9 ,100)
       (n4 , 8  ,6 ,100)
       (n5 , 4  ,12,100)
       (n6 , 3 ,6,100)
       (n7 , 4 ,19 ,100)
       (n8 , 11 ,7 ,100)
       (n9 , 0 ,15,100)
(n10, 12 ,8,100)
========================*/
/*4)=============================
(n1 , 13  ,9,100)
(n2 , 5  ,2 ,100)
       (n3 , 13 , 17 ,100)
       (n4 , 16  ,8 ,100)
       (n5 , 0  ,18,100)
       (n6 , 16 ,0,100)
       (n7 , 2 ,2 ,100)
       (n8 , 7 ,15 ,100)
       (n9 , 16 ,18,100)
(n10, 16 ,19,100)
=================================*/
/*==5)======================
(n1 , 11  ,13,100)
(n2 , 13  ,14 ,100)
       (n3 , 13 , 6 ,100)
       (n4 , 18  ,6 ,100)
       (n5 , 10  ,4,100)
       (n6 , 14 ,11,100)
       (n7 , 19 ,6 ,100)
       (n8 , 7 ,15 ,100)
       (n9 , 16 ,18,100)
(n10, 15 ,3,100)
=========================*/
/*6)
(n1 , 6  ,0 ,25),
				(n2 , 2  ,0 ,25),
				(n3 , 6  ,7 ,25),
				(n4 , 5  ,5 ,25),
				(n5 , 8  ,6,25),
				(n6 , 4 ,8 ,25),
				(n7 , 1 ,9 ,25),
				(n8 , 2 ,0 ,25),
				(n9 , 2 ,1,25),
				(n10 ,3 ,7,25)*/

/*6)===========================
(n1 , 6  ,0 ,100)
				(n2 , 1  ,0 ,100)
				(n3 , 6  ,6 ,100)
				(n4 , 5  ,5 ,100)
				(n5 , 8  ,6,100)
				(n6 , 4 ,8 ,100)
				(n7 , 1 ,9 ,100)
				(n8 , 4 ,0 ,100)
				(n9 , 2 ,2,100)
				(n10 ,3 ,7,100)
*/

/*7)
            (n1 , 7  ,4 ,100)
				(n2 , 8  ,0 ,100)
				(n3 , 13  ,5 ,100)
				(n4 , 9  ,3 ,100)
				(n5 , 0  ,12,100)
				(n6 , 5 ,11 ,100)
				(n7 , 19 ,2 ,100)
				(n8 , 4 ,11 ,100)
				(n9 , 0 ,10,100)
				(n10 ,1 ,16,100)
*/
/*8)


      /* (n1 , 5  ,5,25),
       (n2 , 5  ,8 ,25),
       (n3 , 7  ,7 ,25),
       (n4 , 9  ,9 ,25),
       (n5 , 8  ,11,25),
       (n6 , 12 ,9,25),
       (n7 , 14 ,7 ,25),
       (n8 , 15 ,9 ,25),
       (n9 , 16 ,11,25),
       (n10, 15 ,13,25)*/
/*9)*/




/*===20======20==========20*/
/*20_0)
(n1 , 5  ,5 ,100)
(n2 , 5  ,8 ,100)
(n3 , 7  ,7 ,100)
(n4 , 9  ,9 ,100)
(n5 , 8  ,11,100)
(n6 , 12 ,9 ,100)
(n7 , 14 ,7 ,100)
(n8 , 15 ,9 ,100)
(n9 , 16 ,11,100)
(n10 ,15 ,13,100)
(n11 ,5  ,14,100)
(n12 ,6  ,13,100)
(n13 ,6  ,12,100)
(n14 ,12 ,15,100)
(n15 ,10 ,13,100)
(n16 ,7  ,17,100)
(n17 ,10 ,17,100)
(n18 ,9  ,18,100)
(n19 ,10 ,20,100)
(n20,13  ,20,100)
(n20,13  ,20,100)*/
/*20_1)================
(n1 , 6  ,10 ,100)
(n2 , 2  ,10 ,100)
(n3 , 16  ,17 ,100)
(n4 , 15  ,15 ,100)
(n5 , 8  ,6,100)
(n6 , 4 ,18 ,100)
(n7 , 11 ,19 ,100)
(n8 , 12 ,0 ,100)
(n9 , 12 ,1,100)
(n10 ,3 ,7,100)
(n11 ,19  ,1,100)
(n12 ,10  ,5,100)
(n13 ,14  ,9,100)
(n14 ,12  ,11,100)
(n15 ,19 ,20,100)
(n16 ,1 ,11,100)
(n17 ,15  ,13,100)
(n18 ,14 ,10,100)
(n19 ,19  ,15,100)
(n20,1  ,5,100)
*/
/*20_2)=============
(n1 , 6  ,7 ,100)
(n2 , 2  ,14 ,100)
(n3 , 9  ,9 ,100)
(n4 , 3  ,6 ,100)
(n5 , 1  ,10,100)
(n6 , 18 ,5 ,100)
(n7 , 19 ,10 ,100)
(n8 , 13 ,13 ,100)
(n9 , 9 ,5,100)
(n10 ,2 ,13,100)
(n11 ,17  ,16,100)
(n12 ,8  ,0,100)
(n13 ,18  ,16,100)
(n14 ,0  ,2,100)
(n15 ,2 ,7,100)
(n16 ,15 ,16,100)
(n17 ,10  ,20,100)
(n18 ,19 ,8,100)
(n19 ,19  ,1,100)
(n20,17  ,15,100)
===================
     3_1)
(n1 , 19  ,1,100)
       (n2 , 10  ,5 ,100)
       (n3 , 14  ,9 ,100)
       (n4 , 12  ,11 ,100)
       (n5 , 19  ,16,100)
       (n6 , 1 ,11,100)
       (n7 , 15 ,13 ,100)
       (n8 , 14 ,10 ,100)
       (n9 , 19 ,15,100)
       (n10, 1 ,12,100)
(n11 ,5  ,0,100)
(n12 ,8  ,0,100)
(n13 ,18  ,16,100)
(n14 ,0  ,2,100)
(n15 ,2 ,7,100)
(n16 ,15 ,16,100)
(n17 ,10  ,20,100)
(n18 ,19 ,8,100)
(n19 ,15  ,17,100)
(n20,17  ,15,100)

/*4_2)=====================================
       (n1 , 2  ,10,100)
       (n2 , 16  ,17 ,100)
       (n3 , 15 , 15 ,100)
       (n4 , 8  ,6 ,100)
       (n5 , 4  ,18,100)
       (n6 , 11 ,19,100)
       (n7 , 15 ,13 ,100)
       (n8 , 14 ,10 ,100)
       (n9 , 19 ,15,100)
       (n10, 1 ,12,100)
(n11 ,6  ,9,100)
(n12 ,13  ,19,100)
(n13 ,7   ,10,100)
(n14 ,6   ,3,100)
(n15 ,12 ,8,100)
(n16 ,17 ,13,100)
(n17 ,6  ,15,100)
(n18 ,7 ,14,100)
(n19 ,5  ,18,100)
(n20,3  ,3,100)
*/
/*5_3)
(n1 , 10  ,19,100)
(n2 , 15  ,1 ,100)
       (n3 , 12 , 9 ,100)
       (n4 , 8  ,6 ,100)
       (n5 , 4  ,12,100)
       (n6 , 3 ,6,100)
       (n7 , 4 ,19 ,100)
       (n8 , 11 ,7 ,100)
       (n9 , 0 ,15,100)
       (n10, 12 ,8,100)
(n11 ,6  ,2,100)
(n12 ,9  ,15,100)
(n13 ,0   ,8,100)
(n14 ,15   ,12,100)
(n15 ,17 ,11,100)
(n16 ,6 ,4,100)
(n17 ,5  ,11,100)
(n18 ,8 ,1,100)
(n19 ,11  ,3,100)
(n20,16  ,11,100)
*/
       /*6_4)==========================
       (n1 , 13  ,9,100)
       (n2 , 5  ,2 ,100)
       (n3 , 13 , 17 ,100)
       (n4 , 16  ,8 ,100)
       (n5 , 0  ,18,100)
       (n6 , 16 ,0,100)
       (n7 , 2 ,2 ,100)
       (n8 , 7 ,15 ,100)
       (n9 , 16 ,18,100)
      (n10, 16 ,19,100)

(n11 ,4  ,10,100)
(n12 ,18  ,17,100)
(n13 ,1  ,16,100)
(n14 ,6   ,19,100)
(n15 ,6 ,5,100)
(n16 ,19 ,11,100)
(n17 ,5  ,1,100)
(n18 ,2 ,6,100)
(n19 ,14  ,13,100)
(n20,18  ,5,100)
*/
/*(n1 , 5  ,5 ,100)
(n2 , 5  ,8 ,100)
(n3 , 7  ,7 ,100)
(n4 , 9  ,9 ,100)
(n5 , 8  ,11,100)
(n6 , 12 ,9 ,100)
(n7 , 14 ,7 ,100)
(n8 , 15 ,9 ,100)
(n9 , 16 ,11,100)
(n10 ,15 ,13,100)*/
/*7_10*/
/*(n1 , 19  ,18 ,100)
(n2 , 1   ,0 ,100)
(n3 , 5  ,15 ,100)
(n4 , 1   ,18 ,100)
(n5 , 20   ,5,100)
(n6 , 15  ,1 ,100)
(n7 , 7 ,16 ,100)
(n8 , 19 ,10 ,100)
(n9 , 3 ,12,100)
(n10 ,10 ,5,100)
(n11 ,0  ,20,100)
(n12 ,3  ,16,100)
(n13 ,2  ,20,100)
(n14 ,5   ,19,100)
(n15 ,20 ,18,100)
(n16 ,5 ,16,100)
(n17 ,1  ,17,100)
(n18 ,1 ,13,100)
(n19 ,1  ,15,100)
(n20,3  ,19,100)*/
/*
(n21 ,5  ,2,100)
(n22 ,18  ,17,100)
(n23 ,1  ,16,100)
(n24 ,6   ,19,100)
(n25 ,6 ,5,100)
(n26 ,19 ,11,100)
(n27 ,5  ,1,100)
(n28 ,2 ,6,100)
(n29 ,14  ,13,100)
(n30,18  ,5,100)


/*(n21 ,4  ,10,100)
(n22 ,18  ,17,100)
(n23 ,1  ,16,100)
(n24 ,6   ,19,100)
(n25 ,6 ,5,100)
(n26 ,19 ,11,100)
(n27 ,5  ,1,100)
(n28 ,2 ,6,100)
(n29 ,14  ,13,100)
(n30,18  ,5,100)
/*8_9*/


/*(n1 , 8  ,15 ,100)
(n2 , 12  ,17 ,100)
(n3 , 11  ,6 ,100)
(n4 , 4  ,8 ,100)
(n5 , 11  ,18,100)
(n6 , 1 ,11 ,100)
(n7 , 3 ,16 ,100)
(n8 , 11 ,2 ,100)
(n9 , 19 ,15,100)
(n10 ,18 ,10,100)

(n11 ,17  ,4,100)
(n12 ,18  ,6,100)
(n13 ,6  ,2,100)
(n14 ,3   ,9,100)
(n15 ,11 ,19,100)
(n16 ,17 ,6,100)
(n17 ,0  ,6,100)
(n18 ,3 ,11,100)
(n19 ,3  ,13,100)
(n20,12  ,4,100)*/
       (n1 , 11  ,5,100)
       (n2 , 16   ,2 ,100)
       (n3 , 7  ,4 ,100)
       (n4 , 13  ,8 ,100)
       (n5 , 16  ,5,100)
       (n6 , 10 ,10,100)
       (n7 , 7 ,10 ,100)
       (n8 , 9 ,17 ,100)
       (n9 , 0 ,1,100)
       (n10, 15 ,16,100)
(n11 ,12  ,0,100)
(n12 ,0 ,3,100)
(n13 ,7  ,2,100)
(n14 ,18  ,12,100)
(n15 ,11 ,2,100)
(n16 ,10 ,16,100)
(n17 ,1  ,15,100)
(n18 ,8 ,13,100)
(n19 ,10 ,17,100)
(n20,15  ,14,100)

;
set Messages:=


/*(m1 , n1 , n6 ,4)
				(m2 , n5 , n7 ,3)
				(m3 , n9 , n4 ,2)
				(m4 , n10, n8 ,3)
            (m5 , n2 , n8 ,5)*/



/*40_3)(m1 , n9 , n1 ,5)
				(m2 , n10 , n2 ,4)
				(m3 , n2 , n1 ,1)
				(m4 , n7, n1 ,2)
            (m5 , n8 , n2 ,4)*/
/*(m1 , n9 , n1 ,5)
				(m2 , n5 , n4 ,5)
				(m3 , n2 , n1 ,1)
				(m4 , n6, n1 ,1)
            (m5 , n5 , n3 ,2)*/
(m1 , n9 , n1 ,4)
(m2 , n5 , n4 ,5)
(m3 , n2 , n1 ,1)
(m4 , n6, n1 ,1)
(m5, n5, n3, 2)

;





end;







