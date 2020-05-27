public class EnrollmentUtility {
    public static Enrollment__c fillEnrollment(String cstmrId, String locId, String clsId, Date stDate, String status){
        Enrollment__c enr = new Enrollment__c();
        enr.Location__c   = locId;
        enr.Class__c      = clsId;
        enr.Start_Date__c = stDate;
        enr.Parent__c     = cstmrId;
        enr.Status__c     = status;
        enr.Enrollment_Date__c = System.today();
        return enr;
    }
    
    public static Invoice__c fillInvoice(String cstmrId, String locId, String subsId, String invType, String status){
        Invoice__c invoice = new Invoice__c();
        invoice.Customer__c= cstmrId;
        invoice.Location__c= locId;
        invoice.Subscription__c = subsId;
        invoice.Status__c		= status;
        invoice.Invoice_Type__c = invType;
        invoice.Invoice_Date__c = System.today();
        return invoice;
    }
    
    public static Invoice_Line_Item__c fillInvLineItem(String invId, String enrId, String subLnItmId, String feeId, String disId, String type, Decimal amount){
        Invoice_Line_Item__c invLnItm = new Invoice_Line_Item__c();
        invLnItm.Invoice__c   = invId;
        invLnItm.Enrollment__c= enrId;
        invLnItm.Subscription_Line_Item__c = subLnItmId;
        invLnItm.Fee__c 	  = feeId;
        invLnItm.Discount__c  = disId;
        invLnItm.Type__c      = type;
        invLnItm.Amount__c    = amount;
        return invLnItm;
    }

    public static Payment__c fillPayment(String cstmrId, String invId, String status, Decimal amount){
        Payment__c payment = new Payment__c();
        payment.Parent__c  = cstmrId;
        payment.Invoice__c = invId;
        payment.Amount__c  = amount;
        payment.Status__c  = status;
        payment.Payment_Date__c = System.today();
        return payment;
    }   
}