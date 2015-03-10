trigger createEncryptedKey on CampaignMember (before insert) {
    for (CampaignMember c : Trigger.new) {
        DateTime now = System.now();
        String formattednow = now.formatGmt('yyyy-MM-dd')+'T'+ now.formatGmt('HH:mm:ss')+'.'+now.formatGMT('SSS')+'Z';
        String canonical = c.id + c.Lead.FirstName + c.Lead.LastName + formattednow;
        Blob bsig = Crypto.generateDigest('MD5', Blob.valueOf(canonical));
        String token = EncodingUtil.base64Encode(bsig);

        if(token.length() > 255) { 
            token = token.substring(0,254);
        }//if
        try {
            c.EncryptedKey__c = Encodingutil.urlEncode(token, 'UTF-8').replaceAll('%','_');
        }catch (Exception e){
            system.debug('EncrtpyedKey assignment failed:' +e);
        }
    }//for
}