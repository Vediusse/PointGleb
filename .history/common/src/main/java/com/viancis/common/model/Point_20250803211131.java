package com.viancis.common_point_user.model;


import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.viancis.auth.model.User;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.GenericGenerator;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Date;

@Entity
@Table(name = "points")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Point implements Serializable {

    @Id
    @GeneratedValue(generator = "uuid")
    @GenericGenerator(name = "uuid", strategy = "uuid2")

    private String id;

    @Column(nullable = false)
    private double x;

    @Column(nullable = false)
    private double y;

    @Column(nullable = false)
    private double r;

    @Column(nullable = false)
    private boolean insideArea;

    @CreationTimestamp
    @Column(updatable = false)
    private Date timestamp;

    @Column(nullable = false)
    private long executionTime;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id", nullable = false)
    @JsonBackReference(value = "user-points")
    private User user;


    public Point(double x, double y, double r, boolean insideArea, Date timestamp, long executionTime, User user) {
        this.x = x;
        this.y = y;
        this.r = r;
        this.insideArea = insideArea;
        this.timestamp = timestamp;
        this.executionTime = executionTime;
        this.user = user;
    }


    public Point checkInside() {
        if (x >= 0 && y >= 0) {
            // Треугольник: x + y <= r * 2
            this.insideArea = (x + y <= r * 2);
        } else if (x <= 0 && y >= 0) {
            // Круг: x^2 + y^2 <= r^2
            this.insideArea = (x * x + y * y <= r * r);
        } else if (x >= 0 && y <= 0) {
            // Квадрат: x и y в пределах от -r * 2 до r * 2
            this.insideArea = (x >= -r * 2 && x <= r * 2 && y >= -r * 2 && y <= r * 2);
        } else {
            // Для всех остальных случаев
            this.insideArea = false;
        }
        return this;
    }

    public boolean isInside(){
        return insideArea;
    }
}