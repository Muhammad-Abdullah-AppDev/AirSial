class UpComingMeetingModel {
  int? tid;
  String? tdate;
  String? refno;
  String? meeting;
  String? committe;
  String? rmks;
  String? fkmeeting;
  String? mdate;
  String? venue;
  String? fkcmt;
  String? mtime;
  String? zM_LINK;
  String? meettime;

  UpComingMeetingModel({
    this.tid,
    this.tdate,
    this.refno,
    this.meeting,
    this.committe,
    this.rmks,
    this.fkmeeting,
    this.mdate,
    this.venue,
    this.fkcmt,
    this.mtime,
    this.zM_LINK,
    this.meettime,
  });

  UpComingMeetingModel.fromJson(Map<String, dynamic> json) {
    tid = json['TID'];
    tdate = json['TDATE'];
    refno = json['REFNO'];
    meeting = json['MEETING'];
    committe = json['COMMITTE'];
    rmks = json['RMKS'];
    fkmeeting = json['FKMEETING'];
    mdate = json['MDATE'];
    venue = json['VENUE'];
    fkcmt = json['FKCMT'];
    mtime = json['MTIME'];
    zM_LINK = json['ZM_LINK'];
    meettime = json['MTIME'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TID'] = this.tid;
    data['TDATE'] = this.tdate;
    data['REFNO'] = this.refno;
    data['MEETING'] = this.meeting;
    data['COMMITTE'] = this.committe;
    data['RMKS'] = this.rmks;
    data['FKMEETING'] = this.fkmeeting;
    data['MDATE'] = this.mdate;
    data['VENUE'] = this.venue;
    data['FKCMT'] = this.fkcmt;
    data['MTIME'] = this.mtime;
    data['ZM_LINK'] = this.zM_LINK;
    data['MTIME'] = this.meettime;
    return data;
  }
}
