package com.smarttravel.backend;

import com.smarttravel.backend.common.PasswordPolicy;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class PasswordPolicyTest {
    @Test
    void acceptsLongAsciiButRejectsUtf8BeyondBcryptLimitAndBlankPasswords() {
        assertDoesNotThrow(() -> PasswordPolicy.validate("a".repeat(72)));
        assertThrows(IllegalArgumentException.class, () -> PasswordPolicy.validate("a".repeat(73)));
        assertThrows(IllegalArgumentException.class, () -> PasswordPolicy.validate("ệ".repeat(25)));
        assertThrows(IllegalArgumentException.class, () -> PasswordPolicy.validate("short"));
        assertThrows(IllegalArgumentException.class, () -> PasswordPolicy.validate("        "));
    }
}
