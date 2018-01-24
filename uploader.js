// :::::::: 자르갈 :::::::::::

function init(){
    document.getElementById('localFileSelector').addEventListener('change', getLocalFile, false);
}
init();



var apiURL = "";
// 이미지 올릴 url 입력 
function setServerUrl(){
    apiURL = $("#server_url_input").val();
    console.log("server url: " + url);
}


// 로컬로 저장되어 있는경우 파일 선택
var files = [];
function getLocalFile(evt){
    console.log(":::::: getLocalFile ::::::");
    files = evt.target.files;
}

// 이미지가 blob으로 되어 있는 경우
function getBlob(){
    return new Blob([content], { type: "text/xml"});
}

function upload(){
    console.log(files);
    if(!apiURL){
        alert("url를 입력해주세요!");
        return;
    }
    sendToServer(files);
}

function sendToServer(files){
    var formData = new FormData();
    formData.append("imageFiles", files);
    $.ajax({
        url: apiURL,
        type: "POST",
        data: formData,
        processData: false,
        contentType: false,
        xhr: function () {
            myXhr = $.ajaxSettings.xhr();
            if (myXhr.upload) {
                myXhr.upload.addEventListener('progress', progressHandlingFunction, false);
            }
            return myXhr;
        },
        success: function(response) {
            alert("업로드하였습니다");
        },
        error: function(jqXHR, textStatus, errorMessage) {
            console.log(errorMessage);
        }
    });
}

function progressHandlingFunction(e) {
    if (e.lengthComputable) {
        var s = parseInt((e.loaded / e.total) * 100);
        console.log(s + "%");
    }
}