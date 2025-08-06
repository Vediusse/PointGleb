package com.viancis.user.service;

import com.viancis.auth.service.CustomUserDetails;
import com.viancis.common_point_user.dto.PointDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.cloud.openfeign.SpringQueryMap;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.concurrent.CompletableFuture;

@FeignClient(name="point", url = "http://localhost:8091")
public interface PointClient {

    @RequestMapping(method = RequestMethod.GET,value = "/api/points/my")
    ResponseEntity<List<PointDTO>> getMyPoints(
            @RequestHeader("Authorization") String bearerToken);
}
