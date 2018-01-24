<% @LANGUAGE ="VBSCRIPT"%>
<%Option Explicit%>
<!--#include virtual ="/board/Dbconnect/Dbconnect.asp"-->
<!--#include virtual="/include/json.asp"-->
<!--#include virtual="/include/function.asp"-->
<%
Response.ChaRset = "utf-8" 
Response.AddHeader "Access-Control-Allow-Origin", "*"
Response.AddHeader "Access-Control-Allow-Methods", "GET, POST, OPTIONS"
Response.AddHeader "Access-Control-Allow-Credentials", "true"
Response.AddHeader "Access-Control-Allow-Headers","X-Requested-With"
Response.AddHeader "Access-Control-Max-Age", "86400" 
'Response.ChaRset = "UTF-8" 

  DIM rs, SQL, sql_where, sql_select, sql_group, sql_order, sql_option
  dim currentPage,G_PAGE_SIZE, totalcount, totalpage
  
  
  Dim sRtn_jsonText
  Dim clsJson, retJsonText
  dim max_date,searchClub_Name
  
 	Set Rs = Server.CreateObject("ADODB.RecordSet")
	searchClub_Name		= trim(request("searchClub_Name"))
	max_date			= trim(request("max_date"))
		
	currentPage			= trim(request("currentPage"))
	G_PAGE_SIZE			= trim(request("G_PAGE_SIZE"))

	if currentPage = "" then currentPage = 1
	if G_PAGE_SIZE = "" then G_PAGE_SIZE = 10
	

	if max_date <> "" then
		max_date = left(max_date,4) & "-" & mid(max_date,5,2) & "-" & mid(max_date,7,2) & " " & mid(max_date,9,2) & ":" & mid(max_date,11,2) & ":" &mid(max_date,13,2)
	end if

  call Log_AccessPath(Request.ServerVariables("url"), Request.ServerVariables("QUERY_STRING"))


	Set clsJson = new JSON
		sql_select =				"CH.ClubImageUrl,CH.club_tel,CH.club_seq, country country_name, club_states as state_name, club_city as city_name, CLUB_NAME, '' as local_name, CH.City_seq, "
		sql_select = sql_select  & 	" CH.country_seq, ROUND(CH.x, 6) clubx, ROUND(CH.y, 6) cluby, Status_Map, Status_ScoreCard,  Status_GpsByHole,  default_map, count(holeUID) hole_scale, map_advisor, map_redate, "
		sql_select = sql_select  & 	" convert(varchar(10), CH.redate,112) +replace(convert(varchar, CH.redate,108) ,':','') as redate , "
		sql_select = sql_select  & 	" review_rate = (SELECT AVG(value) FROM review WHERE CH.club_seq= review.type_seq and review.type=18)"
		
	'	sql = sql  & 			" from clubhouse CH "
		
		sql_where = sql_where  & 			"	left join country CN on CH.country_seq = CN.country_seq "
		sql_where = sql_where  & 			"	left join CITY CT on CH.city_seq = CT.city_seq "
		sql_where = sql_where  & 			"	left join HoleMap HM on HM.club_seq = CH.club_seq  "
		'sql_where = sql_where  & 			"	left join review on CH.club_seq= review.type_seq and review.type=18 "
		
		'sql_where = sql_where  & 			" where 1=1 and status_gpsbyhole ='Y'  "
		sql_where = sql_where  & 			" where  (isPublished = 'Y' or isPublished is null) and  1=1 and not (CH.x = 0 or CH.x is null or CH.y = 0 or CH.y is null)  "
		if max_date > "" then 
			sql_where = sql_where	 & 	"	and CH.redate > '@max_date' "
		end if
		sql_where = sql_where		 & 	"	and CH.CLUB_NAME like '%@CLUB_NAME%' "

		sql_where = replace(sql_where, "@CLUB_NAME", searchClub_Name)
		sql_where = replace(sql_where, "@max_date", max_date)
  	  
  		sql_group = sql_group & 	" group by CH.ClubImageUrl, CH.club_tel,CH.club_seq, country, club_states, club_city, CLUB_NAME, CH.Local_Name, CH.City_seq,  "
		sql_group = sql_group  & 	" 	CH.country_seq, CH.x, CH.y, Status_Map, Status_ScoreCard,  Status_GpsByHole, default_map, map_advisor, map_redate, convert(varchar(10), CH.redate,112) +replace(convert(varchar, CH.redate,108) ,':','') "

		sql_order = " order by ch.CLUB_NAME  "
  	   
		sql_option = " OFFSET " & cdbl(currentPage-1) *  cdbl(G_PAGE_SIZE) & " ROWS " & " FETCH NEXT " & cdbl(G_PAGE_SIZE) + 1 & " ROWS ONLY"
	   sql = "select " & sql_select & " from clubhouse CH " &  sql_where & sql_group & sql_order & sql_option

  		rs.CursorLocation = 3
		rs.CursorType	= 3
		rs.LockType = 3
	   
		rs.Open(sql), DBCon ,2,1

	   dim moreFlag
	   moreFlag = "N"
		if (rs.recordcount > cint(G_PAGE_SIZE)) then
	    moreFlag = "Y"
	  	else 
	    moreFlag = "N"
	  end if
	
	   retJsonText = "{"
		retJsonText = retJsonText	& toJson("moreFlag",  moreFlag)
	   retJsonText = retJsonText	& ", ""resultSet"":["
	
	if (rs.BOF and rs.EOF) then
  		retJsonText = retJsonText & "]}"
	    Response.Write(retJsonText)
	    Response.End 
    end if
     
	dim record_index
	record_index = 0
    do until (rs.eof or record_index>cint(G_PAGE_SIZE)-1)
  		 retJsonText =	retJsonText		& "{"
  		 retJsonText =	retJsonText		& toJson("club_seq", rs("club_seq"))
  		 retJsonText =	retJsonText		& "," & toJson("country_name", rs("country_name"))
  		 retJsonText =	retJsonText		& "," & toJson("country_seq", rs("country_seq"))
  		 retJsonText =	retJsonText		& "," & toJson("state_name", rs("state_name"))
  		 retJsonText =	retJsonText		& "," & toJson("city_name", rs("city_name"))
  		 retJsonText =	retJsonText		& "," & toJson("city_seq", rs("city_seq"))
  		 retJsonText =	retJsonText		& "," & toJson("club_name", rs("club_name"))
  		 retJsonText =	retJsonText		& "," & toJson("local_name", rs("local_name"))

  		 retJsonText =	retJsonText		& "," & toJson("clubx", rs("clubx"))
  		 retJsonText =	retJsonText		& "," & toJson("cluby", rs("cluby"))
  		 retJsonText =	retJsonText		& "," & toJson("ClubImageUrl", rs("ClubImageUrl"))
  		 retJsonText =	retJsonText		& "," & toJson("club_tel", rs("club_tel"))
  		 retJsonText =	retJsonText		& "," & toJson("default_map", rs("default_map"))
  		 retJsonText =	retJsonText		& "," & toJson("status_map", rs("status_map"))
  		 retJsonText =	retJsonText		& "," & toJson("status_gpsbyhole", rs("status_gpsbyhole"))
  		 retJsonText =	retJsonText		& "," & toJson("hole_scale", rs("hole_scale"))
  		 retJsonText =	retJsonText		& "," & toJson("status_scorecard", rs("status_scorecard"))
  		 retJsonText =	retJsonText		& "," & toJson("redate", rs("redate"))
  		 retJsonText =	retJsonText		& "," & toJson("review_rate", rs("review_rate"))
  		 retJsonText =	retJsonText		& "," & toJson("map_advisor", rs("map_advisor"))
  		 retJsonText =	retJsonText		& "," & toJson("map_redate", rs("map_redate"))
  		 retJsonText =	retJsonText		& "},"	
  		 record_index = record_index + 1
       rs.movenext
  loop
  rs.close()

  retJsonText = retJsonText & "]}"
  retJsonText = replace(retJsonText, "},]}",  "}]}" )	  
  
  	Response.Write(retJsonText)
%>