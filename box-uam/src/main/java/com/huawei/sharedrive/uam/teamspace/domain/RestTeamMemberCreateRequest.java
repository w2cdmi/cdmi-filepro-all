package com.huawei.sharedrive.uam.teamspace.domain;

public class RestTeamMemberCreateRequest {
    private String teamRole;

    private RestTeamMember member;

    private String role;
    
    public static final String ROLE_ADMIN = "admin";
    public static final String ROLE_MANAGER = "manager";
    public static final String ROLE_MEMBER = "member";

    public String getTeamRole() {
        return teamRole;
    }

    public void setTeamRole(String teamRole) {
        this.teamRole = teamRole;
    }

    public RestTeamMember getMember() {
        return member;
    }

    public void setMember(RestTeamMember member) {
        this.member = member;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }
}
