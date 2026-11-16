package com.smarttravel.backend.features.auth.repository;

import com.smarttravel.backend.features.auth.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.List;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import jakarta.persistence.LockModeType;

public interface UserRepository extends JpaRepository<User, Long> {
    @org.springframework.data.jpa.repository.Query("""
            select u from User u where (:role='ALL' or u.role=:role) and (:status='ALL' or u.status=:status)
            and (:search='' or locate(:search, lower(u.fullName))>0 or locate(:search, lower(u.email))>0)
            order by u.createdAt desc,u.id desc
            """)
    org.springframework.data.domain.Slice<User> adminPage(String search, String role, String status,
            org.springframework.data.domain.Pageable page);
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select u from User u where u.email = :email")
    Optional<User> lockByEmail(String email);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select u from User u where u.id = :id")
    Optional<User> lockById(Long id);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select u from User u where u.role = 'ROLE_ADMIN' order by u.id")
    List<User> lockAdministrators();
}
