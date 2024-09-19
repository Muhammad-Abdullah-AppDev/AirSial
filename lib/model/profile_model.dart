class ProfileModel {
  final String? fKUNIT;
  final String? fOLNO;
  final dynamic cDCNO;
  final String? sHNAME;
  final dynamic sHFNAME;
  final dynamic aDRS;
  final dynamic fKCATG;
  final dynamic fKOCUP;
  final dynamic fKCITY;
  final String? cNIC;
  final dynamic nTN;
  final dynamic fILER;
  final dynamic rESIDENT;
  final dynamic zAKAT;
  final dynamic zKTREASON;
  final dynamic tAX;
  final dynamic tAXEXDATE;
  final dynamic mANDATE;
  final dynamic jHOLD;
  final dynamic bANKACNO;
  final dynamic bANKNAME;
  final dynamic bRANCHNAME;
  final double? hOLDING;
  final dynamic mOBILENO;
  final dynamic pHONENO;
  final dynamic iBNNO;
  final dynamic eMAILID;
  final dynamic aCTITLE;
  final dynamic nATIONALITY;
  final dynamic fKSCATG;
  final dynamic sCATGREF;
  final dynamic mEMORANDUM;
  final String? cOCD;
  final String? fKDOCSTS;
  final dynamic iMAGE;
  final String? dTOKEN;
  final dynamic cNICEXPDATE;
  final dynamic cACATG;
  final List<dynamic>? cADIRINFOes;
  final dynamic cAFILER;
  final List<dynamic>? cALDGRs;
  final dynamic cAOCUP;
  final dynamic cASCATG;

  ProfileModel({
    this.fKUNIT,
    this.fOLNO,
    this.cDCNO,
    this.sHNAME,
    this.sHFNAME,
    this.aDRS,
    this.fKCATG,
    this.fKOCUP,
    this.fKCITY,
    this.cNIC,
    this.nTN,
    this.fILER,
    this.rESIDENT,
    this.zAKAT,
    this.zKTREASON,
    this.tAX,
    this.tAXEXDATE,
    this.mANDATE,
    this.jHOLD,
    this.bANKACNO,
    this.bANKNAME,
    this.bRANCHNAME,
    this.hOLDING,
    this.mOBILENO,
    this.pHONENO,
    this.iBNNO,
    this.eMAILID,
    this.aCTITLE,
    this.nATIONALITY,
    this.fKSCATG,
    this.sCATGREF,
    this.mEMORANDUM,
    this.cOCD,
    this.fKDOCSTS,
    this.iMAGE,
    this.dTOKEN,
    this.cNICEXPDATE,
    this.cACATG,
    this.cADIRINFOes,
    this.cAFILER,
    this.cALDGRs,
    this.cAOCUP,
    this.cASCATG,
  });

  ProfileModel.fromJson(Map<String, dynamic> json)
      : fKUNIT = json['FKUNIT'] as String?,
        fOLNO = json['FOLNO'] as String?,
        cDCNO = json['CDCNO'],
        sHNAME = json['SHNAME'] as String?,
        sHFNAME = json['SHFNAME'],
        aDRS = json['ADRS'],
        fKCATG = json['FKCATG'],
        fKOCUP = json['FKOCUP'],
        fKCITY = json['FKCITY'],
        cNIC = json['CNIC'] as String?,
        nTN = json['NTN'],
        fILER = json['FILER'],
        rESIDENT = json['RESIDENT'],
        zAKAT = json['ZAKAT'],
        zKTREASON = json['ZKT_REASON'],
        tAX = json['TAX'],
        tAXEXDATE = json['TAX_EX_DATE'],
        mANDATE = json['MANDATE'],
        jHOLD = json['JHOLD'],
        bANKACNO = json['BANK_ACNO'],
        bANKNAME = json['BANK_NAME'],
        bRANCHNAME = json['BRANCH_NAME'],
        hOLDING = json['HOLDING'],
        mOBILENO = json['MOBILE_NO'],
        pHONENO = json['PHONE_NO'],
        iBNNO = json['IBN_NO'],
        eMAILID = json['EMAIL_ID'],
        aCTITLE = json['AC_TITLE'],
        nATIONALITY = json['NATIONALITY'],
        fKSCATG = json['FKSCATG'],
        sCATGREF = json['SCATG_REF'],
        mEMORANDUM = json['MEMORANDUM'],
        cOCD = json['COCD'] as String?,
        fKDOCSTS = json['FKDOCSTS'] as String?,
        iMAGE = json['IMAGE'],
        dTOKEN = json['DTOKEN'] as String?,
        cNICEXPDATE = json['CNIC_EXP_DATE'],
        cACATG = json['CACATG'],
        cADIRINFOes = json['CADIRINFOes'] as List?,
        cAFILER = json['CAFILER'],
        cALDGRs = json['CALDGRs'] as List?,
        cAOCUP = json['CAOCUP'],
        cASCATG = json['CASCATG'];

  Map<String, dynamic> toJson() => {
    'FKUNIT' : fKUNIT,
    'FOLNO' : fOLNO,
    'CDCNO' : cDCNO,
    'SHNAME' : sHNAME,
    'SHFNAME' : sHFNAME,
    'ADRS' : aDRS,
    'FKCATG' : fKCATG,
    'FKOCUP' : fKOCUP,
    'FKCITY' : fKCITY,
    'CNIC' : cNIC,
    'NTN' : nTN,
    'FILER' : fILER,
    'RESIDENT' : rESIDENT,
    'ZAKAT' : zAKAT,
    'ZKT_REASON' : zKTREASON,
    'TAX' : tAX,
    'TAX_EX_DATE' : tAXEXDATE,
    'MANDATE' : mANDATE,
    'JHOLD' : jHOLD,
    'BANK_ACNO' : bANKACNO,
    'BANK_NAME' : bANKNAME,
    'BRANCH_NAME' : bRANCHNAME,
    'HOLDING' : hOLDING,
    'MOBILE_NO' : mOBILENO,
    'PHONE_NO' : pHONENO,
    'IBN_NO' : iBNNO,
    'EMAIL_ID' : eMAILID,
    'AC_TITLE' : aCTITLE,
    'NATIONALITY' : nATIONALITY,
    'FKSCATG' : fKSCATG,
    'SCATG_REF' : sCATGREF,
    'MEMORANDUM' : mEMORANDUM,
    'COCD' : cOCD,
    'FKDOCSTS' : fKDOCSTS,
    'IMAGE' : iMAGE,
    'DTOKEN' : dTOKEN,
    'CNIC_EXP_DATE' : cNICEXPDATE,
    'CACATG' : cACATG,
    'CADIRINFOes' : cADIRINFOes,
    'CAFILER' : cAFILER,
    'CALDGRs' : cALDGRs,
    'CAOCUP' : cAOCUP,
    'CASCATG' : cASCATG
  };
}