class TravellerInfoModel {
  final int? rEQID;
  final int? tRNO;
  final String? pFIX;
  final String? fIRSTNAME;
  final String? lASTNAME;
  final String? cNIC;
  final String? rELATION;
  final String? dOB;
  final dynamic cREATEDBY;
  final dynamic cREATEDDATE;
  final dynamic mODIFYBY;
  final dynamic mODIFYDATE;
  final dynamic fKDOCSTS;
  final dynamic fTTICKETREQ;

  TravellerInfoModel({
    this.rEQID,
    this.tRNO,
    this.pFIX,
    this.fIRSTNAME,
    this.lASTNAME,
    this.cNIC,
    this.rELATION,
    this.dOB,
    this.cREATEDBY,
    this.cREATEDDATE,
    this.mODIFYBY,
    this.mODIFYDATE,
    this.fKDOCSTS,
    this.fTTICKETREQ,
  });

  TravellerInfoModel.fromJson(Map<String, dynamic> json)
      : rEQID = json['REQID'] as int?,
        tRNO = json['TRNO'] as int?,
        pFIX = json['PFIX'] as String?,
        fIRSTNAME = json['FIRSTNAME'] as String?,
        lASTNAME = json['LASTNAME'] as String?,
        cNIC = json['CNIC'] as String?,
        rELATION = json['RELATION'] as String?,
        dOB = json['DOB'] as String?,
        cREATEDBY = json['CREATEDBY'],
        cREATEDDATE = json['CREATEDDATE'],
        mODIFYBY = json['MODIFYBY'],
        mODIFYDATE = json['MODIFYDATE'],
        fKDOCSTS = json['FKDOCSTS'],
        fTTICKETREQ = json['FTTICKETREQ'];

  Map<String, dynamic> toJson() => {
    'REQID' : rEQID,
    'TRNO' : tRNO,
    'PFIX' : pFIX,
    'FIRSTNAME' : fIRSTNAME,
    'LASTNAME' : lASTNAME,
    'CNIC' : cNIC,
    'RELATION' : rELATION,
    'DOB' : dOB,
    'CREATEDBY' : cREATEDBY,
    'CREATEDDATE' : cREATEDDATE,
    'MODIFYBY' : mODIFYBY,
    'MODIFYDATE' : mODIFYDATE,
    'FKDOCSTS' : fKDOCSTS,
    'FTTICKETREQ' : fTTICKETREQ
  };
}