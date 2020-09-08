package com.huawei.sharedrive.uam.teamspace.service.impl;

import com.huawei.sharedrive.uam.enterprise.dao.EnterpriseAccountDao;
import com.huawei.sharedrive.uam.exception.BusinessException;
import com.huawei.sharedrive.uam.system.service.AppBasicConfigService;
import com.huawei.sharedrive.uam.teamspace.domain.*;
import com.huawei.sharedrive.uam.teamspace.service.TeamSpaceService;
import com.huawei.sharedrive.uam.user.domain.Admin;
import com.huawei.sharedrive.uam.util.BusinessConstants;
import com.huawei.sharedrive.uam.util.PropertiesUtils;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.builder.ToStringBuilder;
import org.apache.shiro.SecurityUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import pw.cdmi.box.domain.Page;
import pw.cdmi.box.domain.PageImpl;
import pw.cdmi.box.domain.PageRequest;
import pw.cdmi.common.domain.AppBasicConfig;
import pw.cdmi.common.domain.enterprise.EnterpriseAccount;
import pw.cdmi.common.util.signature.SignatureUtils;
import pw.cdmi.core.restrpc.RestClient;
import pw.cdmi.core.restrpc.domain.TextResponse;
import pw.cdmi.core.utils.BundleUtil;
import pw.cdmi.core.utils.DateUtils;
import pw.cdmi.core.utils.EDToolsEnhance;
import pw.cdmi.core.utils.JsonUtils;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import java.util.*;

@Component
public class TeamSpaceServiceImpl implements TeamSpaceService
{
    private static final Logger LOGGER = LoggerFactory.getLogger(TeamSpaceServiceImpl.class);
    
    private static final String TEAM_SPACES_URL = "/api/v2/teamspaces";
    
    private static final String RESOURCE_ROLE_URL = "/api/v2/roles";
    
    @Resource
    private RestClient ufmClientService;
    
    @Autowired
    private EnterpriseAccountDao enterpriseAccountDao;
    
    @Autowired
	private AppBasicConfigService appBasicConfigService;
    
    @Autowired
    protected MessageSource messageSource;
    
    @Override
    public RestTeamSpaceInfo changeOwer(Long teamId, String appId, ChangeOwnerRequest request)
    {
        StringBuilder uri = new StringBuilder(TEAM_SPACES_URL);
        uri.append('/').append(teamId).append("/memberships/changeowner");
        
        Map<String, String> headerMap = assembleAccountToken(appId);
        
        TextResponse response = ufmClientService.performJsonPutTextResponse(uri.toString(),
            headerMap,
            request);
        String content = response.getResponseBody();
        
        if (response.getStatusCode() == HttpStatus.OK.value())
        {
            return JsonUtils.stringToObject(content, RestTeamSpaceInfo.class);
        }
        
        LOGGER.info(content);
        throw new BusinessException(content);
        
    }
    
    @Override
    public Page<RestTeamSpaceInfo> getPagedTeamSpace(ListAllTeamSpaceRequest listRequest, String appId,
        PageRequest pageRequest)
    {
        Map<String, String> headerMap = assembleAccountToken(appId);
        
        TextResponse response = ufmClientService.performJsonPostTextResponse(TEAM_SPACES_URL + "/all",
            headerMap,
            listRequest);
        String content = response.getResponseBody();
        List<RestTeamSpaceInfo> list = new ArrayList<RestTeamSpaceInfo>(BusinessConstants.INITIAL_CAPACITIES);
        if (response.getStatusCode() == HttpStatus.OK.value())
        {
            if (StringUtils.isNotBlank(content.substring(content.indexOf("[") + 1, content.indexOf("]"))))
            {
                RestAllTeamSpaceList restTeamSpaceList = JsonUtils.stringToObject(content,
                    RestAllTeamSpaceList.class);
                Long total = restTeamSpaceList.getTotalCount();
                return new PageImpl<RestTeamSpaceInfo>(restTeamSpaceList.getTeamSpaces(), pageRequest,
                    total.intValue());
            }
            return new PageImpl<RestTeamSpaceInfo>(list, pageRequest, list.size());
        }
        
        LOGGER.info(content);
        return new PageImpl<RestTeamSpaceInfo>(list, pageRequest, list.size());
    }
    
    @Override
    public String[] getAllTeamSpaceIds(String appId, String keyword)
    {
        ArrayList<String> teamIds = new ArrayList<String>(BusinessConstants.INITIAL_CAPACITIES);
        Map<String, String> headerMap = assembleAccountToken(appId);
        
        PageRequest pageRequest = null;
        ListAllTeamSpaceRequest request;
        int page = 1;
        TextResponse response = null;
        String content = null;
        while (true)
        {
            pageRequest = new PageRequest(page, 1000);
            request = new ListAllTeamSpaceRequest(pageRequest.getLimit().getLength(),
                Long.valueOf(pageRequest.getLimit().getOffset()));
            response = ufmClientService.performJsonPostTextResponse(TEAM_SPACES_URL + "/all",
                headerMap,
                request);
            content = response.getResponseBody();
            
            if (response.getStatusCode() == HttpStatus.OK.value())
            {
                boolean isBreak = isBreak(content, teamIds);
                if(isBreak)
                {
                    break;
                }
            }
            else
            {
                break;
            }
            
            page++;
        }
        
        return teamIds.toArray(new String[teamIds.size()]);
    }
    
    @Override
    public RestTeamSpaceInfo getTeamSpaceInfo(Long teamId, String appId)
    {
        RestTeamSpaceInfo restTeamSpaceInfo;
        
        try
        {
            String uri = TEAM_SPACES_URL + "/" + teamId;
            
            Map<String, String> headerMap = assembleAccountToken(appId);
            TextResponse response = ufmClientService.performGetText(uri, headerMap);
            String content = response.getResponseBody();
            
            if (response.getStatusCode() == HttpStatus.OK.value())
            {
                restTeamSpaceInfo = JsonUtils.stringToObject(content, RestTeamSpaceInfo.class);
                
                LOGGER.info(ToStringBuilder.reflectionToString(restTeamSpaceInfo));
                return restTeamSpaceInfo;
            }
            LOGGER.error(response.getResponseBody());
            return null;
            
        }
        catch (BusinessException e)
        {
            LOGGER.error(e.getMessage(), e);
            return null;
        }
    }

    @Override
    public RestTeamSpaceInfo createTeamSpace(String appId, RestTeamSpaceCreateRequest request) {
        Map<String, String> headerMap = assembleAccountToken(appId);

        TextResponse response = ufmClientService.performJsonPostTextResponse(TEAM_SPACES_URL, headerMap, request);
        String content = response.getResponseBody();

        if (response.getStatusCode() == HttpStatus.OK.value() || response.getStatusCode() == HttpStatus.CREATED.value()) {
            return JsonUtils.stringToObject(content, RestTeamSpaceInfo.class);
        }

        LOGGER.info(content);
        throw new BusinessException(content);
    }

    @Override
    public RestTeamSpaceInfo createTeamSpace(Long enterpriseId, String appId, RestTeamSpaceCreateRequest request) {
        Map<String, String> headerMap = assembleAccountToken(enterpriseId, appId);

        TextResponse response = ufmClientService.performJsonPostTextResponse(TEAM_SPACES_URL, headerMap, request);
        String content = response.getResponseBody();

        if (response.getStatusCode() == HttpStatus.OK.value() || response.getStatusCode() == HttpStatus.CREATED.value()) {
            return JsonUtils.stringToObject(content, RestTeamSpaceInfo.class);
        }

        LOGGER.info(content);
        throw new BusinessException(content);
    }

    @Override
    public RestTeamSpaceInfo modifyTeamSpace(Long teamId, String appId, RestTeamSpaceModifyRequest spaceModifyRequest)
    {
        StringBuilder uri = new StringBuilder(TEAM_SPACES_URL);
        uri.append('/').append(teamId);

        Map<String, String> headerMap = assembleAccountToken(appId);

        TextResponse response = ufmClientService.performJsonPutTextResponse(uri.toString(),
            headerMap,
            spaceModifyRequest);
        String content = response.getResponseBody();

        if (response.getStatusCode() == HttpStatus.OK.value())
        {
            return JsonUtils.stringToObject(content, RestTeamSpaceInfo.class);
        }

        LOGGER.info(content);
        throw new BusinessException(content);
    }

    /**
     */
    @Override
    public String modifyTeamSpaces(String teamIds, String appId, RestTeamSpaceModifyRequest spaceModifyRequest, String keyword)
    {
        String[] idArray = teamIds.split(",");
        if ("all".equalsIgnoreCase(teamIds))
        {
            idArray = getAllTeamSpaceIds(appId, keyword);
        }
        
        StringBuilder sb = new StringBuilder("");
        for (String teamId : idArray)
        {
            if (StringUtils.isNotBlank(teamId))
            {
                try
                {
                    modifyTeamSpace(Long.valueOf(teamId), appId, spaceModifyRequest);
                }
                catch (NumberFormatException e)
                {
                    LOGGER.warn(new StringBuilder("modifyTeamSpace fail, teamId:").append(teamId)
                        .append(",error:")
                        .append(e.getMessage())
                        .toString());
                    sb.append(',').append(teamId);
                }
            }
        }
        String idFails = sb.toString();
        return idFails;
    }

    @Override
    public void deleteTeamSpace(Long enterpriseId, String appId, Long teamId) {
        Map<String, String> headerMap = assembleAccountToken(enterpriseId, appId);

        TextResponse response = ufmClientService.performDeleteByUri(TEAM_SPACES_URL + "/" + teamId, headerMap);
        String content = response.getResponseBody();

        if (response.getStatusCode() != HttpStatus.OK.value() && response.getStatusCode() != HttpStatus.CREATED.value()) {
            LOGGER.info(content);
            throw new BusinessException(content);
        }
    }

    private Map<String, String> assembleAccountToken(String appId) {
        Admin sessAdmin = (Admin) SecurityUtils.getSubject().getPrincipal();
        long enterpriseId = sessAdmin.getEnterpriseId();
        EnterpriseAccount account = enterpriseAccountDao.getByEnterpriseApp(enterpriseId, appId);
        return assembleAccountToken(account);
    }

    private Map<String, String> assembleAccountToken(long enterpriseId, String appId) {
        EnterpriseAccount account = enterpriseAccountDao.getByEnterpriseApp(enterpriseId, appId);
        return assembleAccountToken(account);
    }

    private Map<String, String> assembleAccountToken(long accountId) {
        EnterpriseAccount enterpriseAccount = enterpriseAccountDao.getByAccountId(accountId);
        return assembleAccountToken(enterpriseAccount);
    }

    private Map<String, String> assembleAccountToken(EnterpriseAccount enterpriseAccount) {
        if (null == enterpriseAccount) {
            return null;
        }
        String decodedKey = EDToolsEnhance.decode(enterpriseAccount.getSecretKey(), enterpriseAccount.getSecretKeyEncodeKey());
        Map<String, String> headers = new HashMap<String, String>(16);
        String dateStr = DateUtils.dataToString(DateUtils.RFC822_DATE_FORMAT, new Date(), null);
        String sign = SignatureUtils.getSignature(decodedKey, dateStr);
        String authorization = "account," + enterpriseAccount.getAccessKeyId() + ',' + sign;
        headers.put("Authorization", authorization);
        headers.put("Date", dateStr);

        return headers;
    }

    @SuppressWarnings("unchecked")
    @Override
    public List<RestNodeRoleInfo> getSystemRoles(String appId)
    {
        List<RestNodeRoleInfo> result;
        
        try
        {
            String uri = RESOURCE_ROLE_URL;
            Map<String, String> headerMap = assembleAccountToken(appId);
            TextResponse response = ufmClientService.performGetText(uri, headerMap);
            String content = response.getResponseBody();
            
            if (response.getStatusCode() == HttpStatus.OK.value())
            {
                result = (List<RestNodeRoleInfo>) JsonUtils.stringToList(content,
                    ArrayList.class,
                    RestNodeRoleInfo.class);
                
                LOGGER.info(ToStringBuilder.reflectionToString(result));
                return result;
            }
            LOGGER.error(response.getResponseBody());
            return null;
        }
        catch (BusinessException e)
        {
            LOGGER.error(e.getMessage(), e);
            return null;
        }
    }
    
    @SuppressWarnings("unchecked")
    @Override
    public List<RestNodeRoleInfo> getSystemRoles(long accountId)
    {
        List<RestNodeRoleInfo> result;
        
        try
        {
            String uri = RESOURCE_ROLE_URL;
            
            Map<String, String> headerMap = assembleAccountToken(accountId);
            TextResponse response = ufmClientService.performGetText(uri, headerMap);
            String content = response.getResponseBody();
            
            if (response.getStatusCode() == HttpStatus.OK.value())
            {
                result = (List<RestNodeRoleInfo>) JsonUtils.stringToList(content,
                    ArrayList.class,
                    RestNodeRoleInfo.class);
                
                LOGGER.info(ToStringBuilder.reflectionToString(result));
                return result;
            }
            LOGGER.error(response.getResponseBody());
            return null;
            
        }
        catch (BusinessException e)
        {
            LOGGER.error(e.getMessage(), e);
            return null;
        }
    }
    
    private boolean isBreak(String content, List<String> teamIds)
    {
        if (StringUtils.isNotBlank(content.substring(content.indexOf("[") + 1, content.indexOf("]"))))
        {
            RestAllTeamSpaceList restTeamSpaceList = JsonUtils.stringToObject(content,
                RestAllTeamSpaceList.class);
            
            for (RestTeamSpaceInfo team : restTeamSpaceList.getTeamSpaces())
            {
                teamIds.add(team.getId() + "");
            }
            
            if (restTeamSpaceList.getTeamSpaces().size() < 1000)
            {
                return true;
            }
        }
        return false;
    }

    @Override
    public RestTeamMemberInfo addTeamSpaceMember(Long enterpriseId, String appId, Long teamId, RestTeamMemberCreateRequest request) {
        String url = "/api/v2/teamspaces/" + teamId + "/memberships";
        Map<String, String> headerMap = assembleAccountToken(enterpriseId, appId);

        TextResponse response = ufmClientService.performJsonPostTextResponse(url, headerMap, request);
        String content = response.getResponseBody();

        if (response.getStatusCode() == HttpStatus.OK.value() || response.getStatusCode() == HttpStatus.CREATED.value()) {
            return JsonUtils.stringToObject(content, RestTeamMemberInfo.class);
        }

        LOGGER.info(content);
        throw new BusinessException(content);
    }

//    @Override
//    public void deleteTeamSpaceMember(Long enterpriseId, String appId, Long teamId, Long memberId) {
//        String url = "/api/v2/teamspaces/" + teamId + "/memberships/" + memberId;
//        Map<String, String> headerMap = assembleAccountToken(enterpriseId, appId);
//
//        ufmClientService.performDelete(url, headerMap);
//    }
    
    @Override
    public void deleteTeamSpaceMemberByCloudUserId(Long enterpriseId, String appId, Long teamId, Long cloudUserId) {
        String url = "/api/v2/teamspaces/" + teamId + "/memberships/deleteMameger/" + cloudUserId;
        Map<String, String> headerMap = assembleAccountToken(enterpriseId, appId);

        
        TextResponse response =  ufmClientService.performDelete(url, headerMap);
        String content = response.getResponseBody();
        if (response.getStatusCode() == HttpStatus.OK.value() ) {
        	return ;
        }
        LOGGER.info(content);
        throw new BusinessException(content);

       
    }

    
    @Override
    public List<RestTeamMemberInfo>  listUserTeamSpaces(Long enterpriseId, String appId, Long memberId, Integer spaceType) {
        String url = "/api/v2/teamspaces/items";
        Map<String, String> headerMap = assembleAccountToken(enterpriseId, appId);

        ListUserTeamSpaceRequest request = new ListUserTeamSpaceRequest();
        request.setUserId(memberId);
        request.setOffset(0L);
        request.setLimit(99);
        request.setType(spaceType);

        TextResponse response = ufmClientService.performJsonPostTextResponse(url, headerMap, request);
        String content = response.getResponseBody();
        List<RestTeamMemberInfo> list = new ArrayList<>(BusinessConstants.INITIAL_CAPACITIES);
        if (response.getStatusCode() == HttpStatus.OK.value()) {
            if (StringUtils.isNotBlank(content.substring(content.indexOf("[") + 1, content.indexOf("]")))) {
                RestUserTeamSpaceList restTeamSpaceList = JsonUtils.stringToObject(content, RestUserTeamSpaceList.class);
                return restTeamSpaceList.getMemberships();
            }
        }

        return list;
    }


    public void createDefaultTeamSpace(long enterpriseId,String appId,int type,String name,String role) {
		// TODO Auto-generated method stub
		AppBasicConfig appBasicConfig = appBasicConfigService.getAppBasicConfig(appId);
		//添加收件箱空间
    	RestTeamSpaceCreateRequest request=new RestTeamSpaceCreateRequest();
        request.setName(name);
        request.setMaxMembers(-1);
        request.setMaxVersions(-1);
        request.setSpaceQuota((long) -1);
        request.setType(type);//收件箱
        request.setRegionId(appBasicConfig.getUserDefaultRegion());
        RestTeamSpaceInfo restInfo=  createTeamSpace(enterpriseId, appId, request);
        
        
        RestTeamMember restTeamMember=new RestTeamMember();
        restTeamMember.setId(RestTeamMember.ID_PUBLIC);
        restTeamMember.setLoginName(RestTeamMember.TYPE_SYSTEM);
        restTeamMember.setName(RestTeamMember.TYPE_SYSTEM);
        restTeamMember.setType(RestTeamMember.TYPE_SYSTEM);
        
        
        RestTeamMemberCreateRequest memberRequest=new RestTeamMemberCreateRequest();
        memberRequest.setMember(restTeamMember);
        memberRequest.setTeamRole(RestTeamMemberCreateRequest.ROLE_MEMBER);
        memberRequest.setRole(role);
        
        addTeamSpaceMember(enterpriseId, appId, restInfo.getId(), memberRequest);
        
        
	}
    
    
    
    
    @PostConstruct
    public void checkIsCreateDefaultTeamSpace(){
    	try {
    		BundleUtil.addBundle("messages", new Locale[]{Locale.ENGLISH, Locale.CHINESE});
        	List<EnterpriseAccount> accountList= enterpriseAccountDao.listAll();
        	for(int i=0;i<accountList.size();i++){
        		EnterpriseAccount enterpriseAccount=accountList.get(i);
        		List<RestTeamSpaceInfo> restlist= getAllTeamSpace(enterpriseAccount);
        		boolean isReciveFolder=false;
        		boolean isArchiveStore=false;
        		for(int j=0;j<restlist.size();j++){
        		
        			if(restlist.get(j).getType()==TeamSpace.TYPE_RECEIVE_FOLDER){
        				isReciveFolder=true;
        			}
        			if(restlist.get(j).getType()==TeamSpace.TYPE_ARCHIVE_STORE){
        				isArchiveStore=true;
        			}
        			
        		}
        		Locale locale;
        		String defalutLang= PropertiesUtils.getProperty("default.system.lang");
        		if(defalutLang.equals("cn")){
        			locale = Locale.CHINESE;
        		}else{
        			locale = Locale.ENGLISH;
        		}
        		//创建默认收件箱
        		if(isReciveFolder==false){
        			String  inbox= BundleUtil.getText("messages",locale, "enterprise.teamspace.inbox");
            		createDefaultTeamSpace(enterpriseAccount.getEnterpriseId(),enterpriseAccount.getAuthAppId(),
            				TeamSpace.TYPE_RECEIVE_FOLDER,inbox,"editor");
        		}
        		//创建默认企业文库
        		if(isArchiveStore==false){
        			String  archivestore= BundleUtil.getText("messages",locale, "enterprise.teamspace.archivestore");
        			createDefaultTeamSpace(enterpriseAccount.getEnterpriseId(),enterpriseAccount.getAuthAppId(),TeamSpace.TYPE_ARCHIVE_STORE,archivestore,"uploadAndView");
        		}
        	}
		} catch (Exception e) {
			// TODO: handle exception
			LOGGER.error("checkIsCreateDefaultTeamSpace fail");
			LOGGER.error(e.getMessage());
		}
   	    
    }

	private List<RestTeamSpaceInfo> getAllTeamSpace(EnterpriseAccount enterpriseAccount) {
		// TODO Auto-generated method stub

        Map<String, String> headerMap = assembleAccountToken(enterpriseAccount);
        PageRequest pageRequest = new PageRequest(1, 1000);
        ListAllTeamSpaceRequest request = new ListAllTeamSpaceRequest(pageRequest.getLimit().getLength(),
                Long.valueOf(pageRequest.getLimit().getOffset()));;
        request.setType(-1);     
        TextResponse response = ufmClientService.performJsonPostTextResponse(TEAM_SPACES_URL + "/all",headerMap, request);;
        String  content = response.getResponseBody();
        if (response.getStatusCode() == HttpStatus.OK.value())
        {
           return JsonUtils.stringToObject(content, RestAllTeamSpaceList.class).getTeamSpaces();
        }
        LOGGER.info(content);
        throw new BusinessException(content);
	}

	@Override
	public void addDepartMember(RestTeamSpaceInfo teamSpaceInfo,String role,long enterpriseId,String appId,String deptName) {
		// TODO Auto-generated method stub
	    
        RestTeamMember restTeamMember=new RestTeamMember();
        restTeamMember.setId(RestTeamMember.ID_PUBLIC);
        restTeamMember.setLoginName(deptName);
        restTeamMember.setName(deptName);
        restTeamMember.setType(RestTeamMember.TYPE_DEPT);
        
        
        RestTeamMemberCreateRequest memberRequest=new RestTeamMemberCreateRequest();
        memberRequest.setMember(restTeamMember);
        memberRequest.setTeamRole(RestTeamMemberCreateRequest.ROLE_MEMBER);
        memberRequest.setRole(role);
        
        addTeamSpaceMember(enterpriseId, appId, teamSpaceInfo.getId(), memberRequest);
	}
}
