public class ContactActionLinkExtension {

private final Contact contact;

public Contact getContact() {
        return contact;
    }
    
public ContactActionLinkExtension(ApexPages.StandardController stdController) {
        contact = [select c.Id, c.Name, c.AccountId from Contact c where id = :ApexPages.currentPage().getParameters().get('id')];
    }
    
public PageReference logCall() {
        PageReference callPage = new PageReference('/00T/e?title=Call&who_id=' + contact.id + '&followup=1&tsk5=Log Call&retURL=%2F' + contact.id);
        callPage.setRedirect(true);
        return callPage;
    }

public PageReference setAppt() {
        PageReference apptPage = new PageReference('/apex/callreport?type=Appointment&contactid=' + contact.id + '&accountid=' + contact.Accountid);
        apptPage.setRedirect(false);
        return apptPage;
    }
public PageReference sendEmail() {
        PageReference emailPage = new PageReference('/_ui/core/email/author/EmailAuthor?p2_lkid=' + contact.id + '&rtype=003&retURL=%2F' + contact.id);
        emailPage.setRedirect(true);
        return emailPage;
    }

  
public PageReference openCase() {
        PageReference casePage = new PageReference('/500/e?retURL=%2F' + contact.id + '&def_contact_id=' + contact.id + '&def_account_id=' + contact.AccountId);
        casePage.setRedirect(true);
        return casePage;
    }

public PageReference updateContact() {
        PageReference updatePage = new PageReference('/cntc/cntcupdate/contactupdate.jsp?who_id=' + contact.id + '&retURL=%2F' + contact.id);        
        updatePage.setRedirect(true);
        return updatePage;
    }
    
public PageReference addReport() {
        PageReference reportPage = new PageReference('/a0A/e?CF00N30000001qNay='+ contact.Name +'&CF00N30000001qNay_lkid='+ contact.id + '&retURL=%2F' + contact.id);        
        reportPage.setRedirect(true);
        return reportPage;
    }

public PageReference addSales() {
        PageReference salesPage = new PageReference('/a0J/e?CF00N30000001qNas='+ contact.name +'&CF00N30000001qNas_lkid='+ contact.id + '&retURL=%2F' + contact.id);        
        salesPage.setRedirect(true);
        return salesPage;
    }
   
public PageReference sendContent() {
        PageReference contentPage = new PageReference('/udd/ContentDistribution/wiz/selectContent.apexp?whatId=' + contact.id + '&retURL=%2F' + contact.id);
        contentPage.setRedirect(true);
        return contentPage;
    }
    
public PageReference viewHistory() {
        PageReference historyPage = new PageReference('/ui/core/ViewAllActivityHistoryPage?retURL=%2F' + contact.id + '&id=' + contact.id);
        historyPage.setRedirect(true);
        return historyPage;
    }

 }