package pw.cdmi.box.disk.teamspace.domain;

import org.apache.commons.lang.StringUtils;

import pw.cdmi.box.disk.utils.FilesCommonUtils;
import pw.cdmi.core.exception.InvalidParamException;

public class RestTeamMemberCreateRequest
{
    private String teamRole;
    
    private RestTeamMember member;
    
    private String role;
    
    public String getTeamRole()
    {
        return teamRole;
    }
    
    public void setTeamRole(String teamRole)
    {
        this.teamRole = teamRole;
    }
    
    public RestTeamMember getMember()
    {
        return member;
    }
    
    public void setMember(RestTeamMember member)
    {
        this.member = member;
    }
    
    public String getRole()
    {
        return role;
    }
    
    public void setRole(String role)
    {
        this.role = role;
    }
    
    public void checkParameter() throws InvalidParamException
    {
        if (StringUtils.isBlank(teamRole))
        {
            throw new InvalidParamException("teamRole is blank");
        }
        
        if (member == null)
        {
            throw new InvalidParamException("member is null");
        }
        
        String userType = member.getType();
        if (StringUtils.isNotBlank(userType))
        {
            if (!"user".equals(userType) && !"group".equals(userType))
            {
                throw new InvalidParamException("member  userType is invalid:" + userType);
            }
        }
        else
        {
            member.setType("user");
        }
        
        FilesCommonUtils.checkNonNegativeIntegers(member.getId());
    }
}
