<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_employee_of_Leave_approve_Reject</fullName>
        <description>Notify employee of Leave approve/Reject</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Leave_Requests/Leave_Request_was_Approved</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_Date</fullName>
        <field>Approval_Date__c</field>
        <formula>NOW()</formula>
        <name>Approval Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_to_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Set Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_to_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Set Status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Leave Request Approval</fullName>
        <actions>
            <name>Notify_employee_of_Leave_approve_Reject</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Leave_Request__c.Approval_Status__c</field>
            <operation>notEqual</operation>
            <value>Pending</value>
        </criteriaItems>
        <description>Notify requester of Approval/Rejection of a Leave Request</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
